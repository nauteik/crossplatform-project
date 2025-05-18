package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
public class OverviewService
{
    private static final Logger logger = Logger.getLogger(OverviewService.class.getName());
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

    // Lấy dữ liệu doanh thu và lợi nhuận 7 ngày gần nhất
    public List<TimeBasedChartData> getRevenueAndProfitOverview() {
        List<TimeBasedChartData> result = new ArrayList<>();
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7 - 1);
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

    // Lấy dữ liệu số lượng bán trong 7 ngày gần nhất
    public List<TimeBasedChartData> getQuantitySoldOverview() {
        List<TimeBasedChartData> result = new ArrayList<>();
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7 - 1);
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

    // Lấy dữ liệu bán theo danh mục sản phẩm trong 7 ngày gần nhất
    public List<CategorySalesData> getCategorySalesOverview() {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7 - 1);

        List<CategorySalesData> result = new ArrayList<>();

        // Lấy danh sách các danh mục sản phẩm
        List<String> categories = productTypeService.getAllProductTypeNames();

        // Duyệt qua các danh mục và lấy số lượng bán cho mỗi danh mục
        for (String category : categories) {
            List<Order> ordersInRange = orderService.getOrdersCreatedBetweenDates(startDate, endDate)
                    .stream()
                    .filter(order -> order.getStatus() == OrderStatus.DELIVERED)
                    .toList();

            int quantitySold = 0;
            double revenue = 0;

            for (Order order : ordersInRange) {
                for (OrderItem item : order.getItems()) {
                    Product product = productService.getProductById(item.getProductId());
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

    // Lấy dữ liệu tổng quan với caching để tăng hiệu năng
    @Cacheable("overviewData")
    public OverviewData getOverview() {
        logger.info("Fetching overview data...");
        
        try {
            // Sử dụng CompletableFuture để lấy dữ liệu song song
            CompletableFuture<Integer> totalUsersFuture = CompletableFuture.supplyAsync(this::getTotalUsers);
            CompletableFuture<Integer> totalOrdersFuture = CompletableFuture.supplyAsync(this::getTotalOrders);
            CompletableFuture<Integer> totalProductTypesFuture = CompletableFuture.supplyAsync(this::getTotalProductTypes);
            CompletableFuture<Integer> totalProductsFuture = CompletableFuture.supplyAsync(this::getTotalProducts);
            CompletableFuture<Integer> newUsersFuture = CompletableFuture.supplyAsync(this::getNewUsersCreateToDay);
            CompletableFuture<Integer> newOrdersFuture = CompletableFuture.supplyAsync(this::getNewOrdersCreateToDay);
            CompletableFuture<Long> totalRevenueFuture = CompletableFuture.supplyAsync(this::getTotalRevenue);
            CompletableFuture<Long> totalProfitFuture = CompletableFuture.supplyAsync(this::getTotalProfit);
            
            // Lấy dữ liệu theo thời gian và danh mục cũng song song
            CompletableFuture<List<TimeBasedChartData>> timeSeriesRevenueFuture = 
                CompletableFuture.supplyAsync(this::getRevenueAndProfitOverview);
            CompletableFuture<List<TimeBasedChartData>> timeSeriesQuantityFuture = 
                CompletableFuture.supplyAsync(this::getQuantitySoldOverview);
            CompletableFuture<List<CategorySalesData>> categorySalesFuture = 
                CompletableFuture.supplyAsync(this::getCategorySalesOverview);
            
            // Chờ tất cả các CompletableFuture hoàn thành
            CompletableFuture.allOf(
                totalUsersFuture, totalOrdersFuture, totalProductTypesFuture, totalProductsFuture,
                newUsersFuture, newOrdersFuture, totalRevenueFuture, totalProfitFuture,
                timeSeriesRevenueFuture, timeSeriesQuantityFuture, categorySalesFuture
            ).join();
            
            // Tạo và trả về đối tượng OverviewData
            logger.info("Overview data fetched successfully");
            return new OverviewData(
                totalUsersFuture.get(),
                totalOrdersFuture.get(),
                totalProductTypesFuture.get(),
                totalProductsFuture.get(), 
                newUsersFuture.get(),
                newOrdersFuture.get(),
                totalRevenueFuture.get(),
                totalProfitFuture.get(),
                timeSeriesRevenueFuture.get(),
                timeSeriesQuantityFuture.get(),
                categorySalesFuture.get()
            );
        } catch (InterruptedException | ExecutionException e) {
            logger.severe("Error getting overview data: " + e.getMessage());
            // Trả về dữ liệu trống trong trường hợp lỗi
            return new OverviewData(0, 0, 0, 0, 0, 0, 0, 0, 
                    new ArrayList<>(), new ArrayList<>(), new ArrayList<>());
        }
    }
}
