package com.example.ecommerceproject.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StatisticsData {
    private List<TimeBasedChartData> timeSeriesRevenueProfitData;
    private List<TimeBasedChartData> timeSeriesQuantityData;

    private List<CategorySalesData> categorySalesRatio;
}