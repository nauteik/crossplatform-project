package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.model.OverviewData;
import com.example.ecommerceproject.service.OverviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/api/overview")
public class OverviewController {

    private final OverviewService overviewService;

    @Autowired
    public OverviewController(OverviewService overviewService) {
        this.overviewService = overviewService;
    }

    @GetMapping
    public ResponseEntity<OverviewData> getOverview() {
        OverviewData overview = overviewService.getOverview();
        return new ResponseEntity<>(overview, HttpStatus.OK);
    }
}