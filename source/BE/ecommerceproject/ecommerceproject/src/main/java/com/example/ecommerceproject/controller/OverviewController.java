package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.model.OverviewData;
import com.example.ecommerceproject.service.OverviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/overview")
public class OverviewController {

    private static final Logger logger = Logger.getLogger(OverviewController.class.getName());
    private final OverviewService overviewService;

    @Autowired
    public OverviewController(OverviewService overviewService) {
        this.overviewService = overviewService;
    }

    @GetMapping
    public ResponseEntity<OverviewData> getOverview() {
        logger.info("Received request for overview data");
        
        try {
            // Thiết lập timeout 25 giây cho API (để tránh H12 Heroku error là 30 giây)
            OverviewData overview = CompletableFuture.supplyAsync(() -> {
                return overviewService.getOverview();
            }).orTimeout(25, TimeUnit.SECONDS).get();
            
            logger.info("Overview data retrieved successfully");
            return new ResponseEntity<>(overview, HttpStatus.OK);
        } catch (Exception e) {
            logger.severe("Error getting overview data: " + e.getMessage());
            // Trả về dữ liệu trống trong trường hợp timeout
            return new ResponseEntity<>(new OverviewData(), HttpStatus.OK);
        }
    }
}