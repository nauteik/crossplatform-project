package com.example.ecommerceproject.model;

 import lombok.Data;
 import lombok.NoArgsConstructor;

 @Data // Nếu sử dụng Lombok
 @NoArgsConstructor // Nếu sử dụng Lombok
// @AllArgsConstructor // Nếu sử dụng Lombok
public class TimeBasedChartData {

    // Represents the time period (e.g., "2023-10-26" for daily, "2023-10" for monthly, "2023" for yearly)
    private String timePeriod;

    // Metrics for the time period (nullable as not all charts use all metrics)
    private Double revenue; // Sử dụng Double (wrapper) để có thể null
    private Double profit;  // Sử dụng Double để có thể null
    private Integer quantitySold; // Sử dụng Integer để có thể null

    // Constructor đầy đủ tham số
    public TimeBasedChartData(String timePeriod, Double revenue, Double profit, Integer quantitySold) {
        this.timePeriod = timePeriod;
        this.revenue = revenue;
        this.profit = profit;
        this.quantitySold = quantitySold;
    }
}
