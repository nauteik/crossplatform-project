package com.example.ecommerceproject.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OverviewData {

    private long totalUsers;
    private long totalOrders;
    private long totalProductTypes;
    private long totalProducts;
    private long newUsers;
    private long newOrders;
    private long totalRevenue;
    private long totalProfit;

    private List<TimeBasedChartData> timeSeriesRevenueProfitData;
    private List<TimeBasedChartData> timeSeriesQuantityData;

    private List<CategorySalesData> categorySalesRatio;
}