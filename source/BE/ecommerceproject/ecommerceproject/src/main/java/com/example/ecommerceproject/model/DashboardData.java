package com.example.ecommerceproject.model;

import java.util.List;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
 @NoArgsConstructor
public class DashboardData {

    // Overall Metrics (Các chỉ số tổng)
    // Lưu ý: Các giá trị này có thể là toàn thời gian hoặc được lọc theo ngày tháng tùy vào logic service
    private long totalUsers;
    private long totalOrders;
    private long totalProductTypes; // Tổng số danh mục
    private long totalProducts;

    // Time-Series Data for Charts (Dữ liệu theo thời gian cho biểu đồ)
    private List<TimeBasedChartData> timeSeriesRevenueProfitData; // Dữ liệu Doanh thu/Lợi nhuận theo thời gian
    private List<TimeBasedChartData> timeSeriesQuantityData; // Dữ liệu Số lượng bán theo thời gian

    // Category Sales Data (Dữ liệu bán theo danh mục)
    private List<CategorySalesData> categorySalesRatio; // Dữ liệu tỷ lệ bán theo danh mục

    // Constructor đầy đủ tham số (Hữu ích khi tạo đối tượng trong service)
    public DashboardData(long totalUsers, long totalOrders, long totalProductTypes, long totalProducts, List<TimeBasedChartData> timeSeriesRevenueProfitData, List<TimeBasedChartData> timeSeriesQuantityData, List<CategorySalesData> categorySalesRatio) {
        this.totalUsers = totalUsers;
        this.totalOrders = totalOrders;
        this.totalProductTypes = totalProductTypes;
        this.totalProducts = totalProducts;
        this.timeSeriesRevenueProfitData = timeSeriesRevenueProfitData;
        this.timeSeriesQuantityData = timeSeriesQuantityData;
        this.categorySalesRatio = categorySalesRatio;
    }


    // --- Getters and Setters (Nếu không dùng Lombok) ---

    public long getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
        this.totalUsers = totalUsers;
    }

    public long getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(long totalOrders) {
        this.totalOrders = totalOrders;
    }

    public long getTotalProductTypes() {
        return totalProductTypes;
    }

    public void setTotalProductTypes(long totalProductTypes) {
        this.totalProductTypes = totalProductTypes;
    }

    public long getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(long totalProducts) {
        this.totalProducts = totalProducts;
    }

    public List<TimeBasedChartData> getTimeSeriesRevenueProfitData() {
        return timeSeriesRevenueProfitData;
    }

    public void setTimeSeriesRevenueProfitData(List<TimeBasedChartData> timeSeriesRevenueProfitData) {
        this.timeSeriesRevenueProfitData = timeSeriesRevenueProfitData;
    }

    public List<TimeBasedChartData> getTimeSeriesQuantityData() {
        return timeSeriesQuantityData;
    }

    public void setTimeSeriesQuantityData(List<TimeBasedChartData> timeSeriesQuantityData) {
        this.timeSeriesQuantityData = timeSeriesQuantityData;
    }

    public List<CategorySalesData> getCategorySalesRatio() {
        return categorySalesRatio;
    }

    public void setCategorySalesRatio(List<CategorySalesData> categorySalesRatio) {
        this.categorySalesRatio = categorySalesRatio;
    }


    // --- toString (Nếu không dùng Lombok) ---
    // @Override
    // public String toString() { ... }
}