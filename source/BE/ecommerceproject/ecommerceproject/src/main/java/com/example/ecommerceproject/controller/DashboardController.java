package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.model.DashboardData;
import com.example.ecommerceproject.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    @Autowired
    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/overview")
    public ResponseEntity<DashboardData> getOverview() {
        DashboardData overview = dashboardService.getYearlyOverview(2025);
        return new ResponseEntity<>(overview, HttpStatus.OK);
    }
}