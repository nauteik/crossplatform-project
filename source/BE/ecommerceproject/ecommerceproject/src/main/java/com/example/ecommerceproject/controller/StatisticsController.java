package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.model.StatisticsData;
import com.example.ecommerceproject.service.StatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.Year;
import java.time.temporal.ChronoUnit;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    private final StatisticsService statisticsService;

    @Autowired
    public StatisticsController(StatisticsService statisticsService) {
        this.statisticsService = statisticsService;
    }

    @GetMapping("/test")
    public ResponseEntity<StatisticsData> test() {
        StatisticsData data = statisticsService.getQuarterlyStatisticsData(null, null);
        return new ResponseEntity<>(data, HttpStatus.OK);
    }

    @GetMapping
    public ResponseEntity<StatisticsData> getStatistics(
            @RequestParam(value = "filterType", defaultValue = "weekly") String filterType,
            @RequestParam(value = "month", required = false) Integer month,
            @RequestParam(value = "quarter", required = false) Integer quarter,
            @RequestParam(value = "year", required = false) Integer year,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate) {

        StatisticsData statisticsData;

        switch (filterType) {
            case "weekly":
                statisticsData = statisticsService.getWeeklyStatisticsData();
                break;
            case "monthly":
                statisticsData = statisticsService.getMonthlyStatisticsData(month, year);
                break;
            case "quarterly":
                statisticsData = statisticsService.getQuarterlyStatisticsData(quarter, year);
                break;
            case "yearly":
                statisticsData = statisticsService.getYearlyStatisticsData(year);
                break;
            case "dateRange":
                statisticsData = statisticsService.getDateRangeStatisticsData(startDate, endDate);
                break;
            default:
                statisticsData = statisticsService.getWeeklyStatisticsData();
                break;
        }

        return new ResponseEntity<>(statisticsData, HttpStatus.OK);
    }
}