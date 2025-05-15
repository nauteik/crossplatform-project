package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.CategorySalesData;
import com.example.ecommerceproject.model.DashboardData;
import com.example.ecommerceproject.model.TimeBasedChartData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class DashboardService {

    private final UserService userService;
    private final OrderService orderService;
    private final ProductService productService;
    private final ProductTypeService productTypeService;

    @Autowired
    public DashboardService(UserService userService, OrderService orderService, ProductService productService, ProductTypeService productTypeService) {
        this.userService = userService;
        this.orderService = orderService;
        this.productService = productService;
        this.productTypeService = productTypeService;
    }

    // Lấy tổng số Users
    public int getTotalUsers() {
        return userService.getUserCount();
    }

    // Lấy tổng số Orders
    public int getTotalOrders() {
        return orderService.getOrderCount();
    }

    // Lấy tổng số Product Types
    public int getTotalProductTypes() {
        return productTypeService.getProductTypeCount();
    }

    // Lấy tổng số Products
    public int getTotalProducts() {
        return productService.getProductCount();
    }

    // Lấy dữ liệu doanh thu và lợi nhuận theo thời gian (mặc định 7 ngày gần nhất)
    public List<TimeBasedChartData> getRevenueAndProfitTimeSeriesData(int days) {
        List<TimeBasedChartData> result = new ArrayList<>();
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(days - 1);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Duyệt qua các ngày trong khoảng thời gian
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String formattedDate = date.format(formatter);

            // Lấy doanh thu và lợi nhuận từ OrderService
            Double revenue = orderService.getRevenueByDate(date);
            Double profit = orderService.getProfitByDate(date);

            // Thêm dữ liệu vào danh sách kết quả
            result.add(new TimeBasedChartData(formattedDate, revenue, profit, null));
        }

        return result;
    }

    // Lấy dữ liệu số lượng bán theo thời gian (mặc định 7 ngày gần nhất)
    public List<TimeBasedChartData> getQuantitySoldTimeSeriesData(int days) {
        List<TimeBasedChartData> result = new ArrayList<>();
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(days - 1);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Duyệt qua các ngày trong khoảng thời gian
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String formattedDate = date.format(formatter);

            // Lấy số lượng bán từ OrderService
            Integer quantitySold = orderService.getQuantitySoldByDate(date);

            // Thêm dữ liệu vào danh sách kết quả
            result.add(new TimeBasedChartData(formattedDate, null, null, quantitySold));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục sản phẩm
    public List<CategorySalesData> getCategorySalesData() {
        List<CategorySalesData> result = new ArrayList<>();

        // Lấy danh sách các danh mục sản phẩm
        List<String> categories = productTypeService.getAllProductTypeNames();

        // Duyệt qua các danh mục và lấy số lượng bán cho mỗi danh mục
        for (String category : categories) {
            int quantitySold = orderService.getQuantitySoldByCategory(category);
            result.add(new CategorySalesData(category, quantitySold));
        }

        return result;
    }

    // Lấy dữ liệu tổng quan cho dashboard trong khoảng thời gian mặc định (7 ngày gần nhất)
    public DashboardData getOverview() {
        return getOverviewForPeriod(7);
    }

    // Lấy dữ liệu tổng quan cho dashboard trong khoảng thời gian tùy chỉnh
    public DashboardData getOverviewForPeriod(int days) {
        // Lấy các chỉ số tổng
        long totalUsers = getTotalUsers();
        long totalOrders = getTotalOrders();
        long totalProductTypes = getTotalProductTypes();
        long totalProducts = getTotalProducts();

        // Lấy dữ liệu theo thời gian
        List<TimeBasedChartData> timeSeriesRevenueProfitData = getRevenueAndProfitTimeSeriesData(days);
        List<TimeBasedChartData> timeSeriesQuantityData = getQuantitySoldTimeSeriesData(days);

        // Lấy dữ liệu bán theo danh mục
        List<CategorySalesData> categorySalesRatio = getCategorySalesData();

        // Tạo và trả về đối tượng DashboardData đầy đủ
        return new DashboardData(
                totalUsers,
                totalOrders,
                totalProductTypes,
                totalProducts,
                timeSeriesRevenueProfitData,
                timeSeriesQuantityData,
                categorySalesRatio
        );
    }

    // Lấy dữ liệu tổng quan theo tháng
    public DashboardData getMonthlyOverview(int month, int year) {
        // Các chỉ số tổng
        long totalUsers = getTotalUsers();
        long totalOrders = getTotalOrders();
        long totalProductTypes = getTotalProductTypes();
        long totalProducts = getTotalProducts();

        // Lấy dữ liệu doanh thu, lợi nhuận và số lượng bán theo tháng
        List<TimeBasedChartData> timeSeriesRevenueProfitData = orderService.getMonthlyRevenueAndProfitData(month, year);
        List<TimeBasedChartData> timeSeriesQuantityData = orderService.getMonthlyQuantitySoldData(month, year);

        // Lấy dữ liệu bán theo danh mục trong tháng
        List<CategorySalesData> categorySalesRatio = orderService.getCategorySalesDataByMonth(month, year);

        return new DashboardData(
                totalUsers,
                totalOrders,
                totalProductTypes,
                totalProducts,
                timeSeriesRevenueProfitData,
                timeSeriesQuantityData,
                categorySalesRatio
        );
    }

    // Lấy dữ liệu tổng quan theo quý
    public DashboardData getQuarterlyOverview(int quarter, int year) {
        // Các chỉ số tổng
        long totalUsers = getTotalUsers();
        long totalOrders = getTotalOrders();
        long totalProductTypes = getTotalProductTypes();
        long totalProducts = getTotalProducts();

        // Lấy dữ liệu doanh thu, lợi nhuận và số lượng bán theo quý
        List<TimeBasedChartData> timeSeriesRevenueProfitData = orderService.getQuarterlyRevenueAndProfitData(quarter, year);
        List<TimeBasedChartData> timeSeriesQuantityData = orderService.getQuarterlyQuantitySoldData(quarter, year);

        // Lấy dữ liệu bán theo danh mục trong quý
        List<CategorySalesData> categorySalesRatio = orderService.getCategorySalesDataByQuarter(quarter, year);

        return new DashboardData(
                totalUsers,
                totalOrders,
                totalProductTypes,
                totalProducts,
                timeSeriesRevenueProfitData,
                timeSeriesQuantityData,
                categorySalesRatio
        );
    }

    // Lấy dữ liệu tổng quan theo năm
    public DashboardData getYearlyOverview(int year) {
        // Các chỉ số tổng
        long totalUsers = getTotalUsers();
        long totalOrders = getTotalOrders();
        long totalProductTypes = getTotalProductTypes();
        long totalProducts = getTotalProducts();

        // Lấy dữ liệu doanh thu, lợi nhuận và số lượng bán theo năm
        List<TimeBasedChartData> timeSeriesRevenueProfitData = orderService.getYearlyRevenueAndProfitData(year);
        List<TimeBasedChartData> timeSeriesQuantityData = orderService.getYearlyQuantitySoldData(year);

        // Lấy dữ liệu bán theo danh mục trong năm
        List<CategorySalesData> categorySalesRatio = orderService.getCategorySalesDataByYear(year);

        return new DashboardData(
                totalUsers,
                totalOrders,
                totalProductTypes,
                totalProducts,
                timeSeriesRevenueProfitData,
                timeSeriesQuantityData,
                categorySalesRatio
        );
    }
}