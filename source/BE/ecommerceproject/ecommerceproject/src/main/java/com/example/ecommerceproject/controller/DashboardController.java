//package com.example.ecommerceproject.controller;
//
//import com.example.ecommerceproject.model.DashboardData;
//import com.example.ecommerceproject.service.DashboardService;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.RestController;
//
//import java.time.LocalDate;
//import java.time.Year;
//import java.time.temporal.ChronoUnit;
//
//@RestController
//@RequestMapping("/api/dashboard")
//public class DashboardController {
//
//    private final DashboardService dashboardService;
//
//    @Autowired
//    public DashboardController(DashboardService dashboardService) {
//        this.dashboardService = dashboardService;
//    }
//
//    @GetMapping("/overview")
//    public ResponseEntity<DashboardData> getOverview() {
//        DashboardData overview = dashboardService.getOverview();
//        return new ResponseEntity<>(overview, HttpStatus.OK);
//    }
//
//    @GetMapping("/statistics")
//    public ResponseEntity<DashboardData> getStatistics(
//            @RequestParam(value = "filterType", defaultValue = "yearly") String filterType,
//            @RequestParam(value = "month", required = false) Integer month,
//            @RequestParam(value = "year", required = false) Integer year,
//            @RequestParam(value = "startDate", required = false) String startDate,
//            @RequestParam(value = "endDate", required = false) String endDate) {
//
//        DashboardData overview;
//
//        switch (filterType) {
//            case "weekly":
//                overview = dashboardService.getOverview();
//                break;
//            case "monthly":
//                if (month == null || year == null) {
//                    month = LocalDate.now().getMonthValue();
//                    year = Year.now().getValue();
//                }
//                overview = dashboardService.getMonthlyOverview(month, year);
//                break;
//            case "yearly":
//                if (year == null) {
//                    year = Year.now().getValue();
//                }
//                overview = dashboardService.getYearlyOverview(year);
//                break;
//            case "dateRange":
//                if (startDate == null || endDate == null) {
//                    startDate = LocalDate.now().toString();
//                    endDate = LocalDate.now().toString();
//                }
//                int daysBetween = (int) ChronoUnit.DAYS.between(LocalDate.parse(startDate), LocalDate.parse(endDate));
//                overview = dashboardService.getOverviewForPeriod(daysBetween + 1);
//                break;
//            default:
//                overview = dashboardService.getOverview();
//                break;
//        }
//
//        return new ResponseEntity<>(overview, HttpStatus.OK);
//    }
//}