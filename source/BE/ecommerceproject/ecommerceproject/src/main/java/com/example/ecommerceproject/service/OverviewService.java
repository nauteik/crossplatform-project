package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OverviewService
{
    private final UserService userService;
    private final OrderService orderService;
    private final ProductService productService;
    private final ProductTypeService productTypeService;

    @Autowired
    public OverviewService(UserService userService, OrderService orderService, ProductService productService, ProductTypeService productTypeService) {
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

    // Lấy số lượng Users mới hôm nay
    public int getNewUsersCreateToDay() {
        LocalDate today = LocalDate.now();
        return userService.getUsersCreatedOnDate(today).size();
    }

    // Lấy số lượng Orders mới hôm nay
    public int getNewOrdersCreateToDay() {
        LocalDate today = LocalDate.now();
        return orderService.getOrdersCreatedOnDate(today).size();
    }

    // Lấy tổng số Revenue
    public long getTotalRevenue() {
        List<Order> allOrders = orderService.getAllOrders();
        return (long) allOrders.stream()
                .filter(order -> order.getStatus() == OrderStatus.DELIVERED)
                .mapToDouble(Order::getTotalAmount)
                .sum();
    }

    // Lấy tổng số Profit
    public long getTotalProfit() {
        List<Order> completedOrders = orderService.getAllOrders().stream()
                .filter(order -> order.getStatus() == OrderStatus.DELIVERED)
                .toList();

        int totalProfit = 0;
        for (Order order : completedOrders) {
            for (OrderItem item : order.getItems()) {
                Product product = productService.getProductById(item.getProductId());
                int quantity = item.getQuantity();
                double costPrice = product.getPrice() - product.getPrice() * 0.2;
                double sellingPrice = product.getPrice();
                // TODO: update totalProfit
                totalProfit += (sellingPrice - costPrice) * quantity;
            }
        }

        return totalProfit;
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
    public List<CategorySalesData> getCategorySalesData(int days) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(days - 1);

        List<CategorySalesData> result = new ArrayList<>();

        // Lấy danh sách các danh mục sản phẩm
        List<String> categories = productTypeService.getAllProductTypeNames();

        // Duyệt qua các danh mục và lấy số lượng bán cho mỗi danh mục
        for (String category : categories) {
            // Get all orders in the date range
            List<Order> ordersInRange = orderService.getOrdersCreatedBetweenDates(startDate, endDate)
                    .stream()
                    .filter(order -> order.getStatus() == OrderStatus.DELIVERED)
                    .toList();

            // Calculate total quantity sold and revenue for this category
            int quantitySold = 0;
            double revenue = 0;

            for (Order order : ordersInRange) {
                for (OrderItem item : order.getItems()) {
                    Product product = productService.getProductById(item.getProductId());
                    // Check if this product belongs to the current category
                    if (product.getProductType().getName().equals(category)) {
                        quantitySold += item.getQuantity();
                        revenue += item.getPrice() * item.getQuantity();
                    }
                }
            }

            CategorySalesData categoryData = new CategorySalesData();
            categoryData.setCategoryName(category);
            categoryData.setTotalQuantitySold(quantitySold);
            result.add(categoryData);
        }

        return result;
    }

    // Lấy dữ liệu tổng quan cho dashboard trong khoảng thời gian mặc định (7 ngày gần nhất)
    public OverviewData getOverview() {
        return getOverviewForPeriod(7);
    }

    // Lấy dữ liệu tổng quan cho dashboard trong khoảng thời gian tùy chỉnh
    public OverviewData getOverviewForPeriod(int days) {
        // Lấy các chỉ số tổng
        long totalUsers = getTotalUsers();
        long totalOrders = getTotalOrders();
        long totalProductTypes = getTotalProductTypes();
        long totalProducts = getTotalProducts();
        long newUsers = getNewUsersCreateToDay();
        long newOrders = getNewOrdersCreateToDay();
        long totalRevenue = getTotalRevenue();
        long totalProfit = getTotalProfit();

        // Lấy dữ liệu theo thời gian
        List<TimeBasedChartData> timeSeriesRevenueProfitData = getRevenueAndProfitTimeSeriesData(days);
        List<TimeBasedChartData> timeSeriesQuantityData = getQuantitySoldTimeSeriesData(days);

        // Lấy dữ liệu bán theo danh mục
        List<CategorySalesData> categorySalesRatio = getCategorySalesData(days);

//        for (CategorySalesData categorySalesData : categorySalesRatio) {
//            System.out.println(categorySalesData);
//        }

        // Tạo và trả về đối tượng DashboardData đầy đủ
        return new OverviewData(
                totalUsers,
                totalOrders,
                totalProductTypes,
                totalProducts,
                newUsers,
                newOrders,
                totalRevenue,
                totalProfit,
                timeSeriesRevenueProfitData,
                timeSeriesQuantityData,
                categorySalesRatio
        );
    }
}
