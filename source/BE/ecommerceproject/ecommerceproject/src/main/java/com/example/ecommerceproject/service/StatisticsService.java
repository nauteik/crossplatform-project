package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class StatisticsService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    private final UserService userService;
    private final OrderService orderService;
    private final ProductService productService;
    private final ProductTypeService productTypeService;

    @Autowired
    public StatisticsService(UserService userService, OrderService orderService, ProductService productService, ProductTypeService productTypeService) {
        this.userService = userService;
        this.orderService = orderService;
        this.productService = productService;
        this.productTypeService = productTypeService;
    }

    // ---------- Start of Daily ----------



    // ---------- End of Daily ----------

    // ---------- Start of DateRange ----------

    // Lấy dữ liệu doanh thu và lợi nhuận trong khoảng thời gian (phân theo ngày)
    public List<TimeBasedChartData> getDateRangeRevenueAndProfitData(LocalDate startDate, LocalDate endDate) {
        List<TimeBasedChartData> result = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String formattedDate = date.format(formatter);

            Double revenue = orderService.getRevenueByDate(date);
            Double profit = orderService.getProfitByDate(date);

            result.add(new TimeBasedChartData(formattedDate, revenue, profit, null));
        }

        return result;
    }

    // Lấy dữ liệu số lượng sản phẩm bán trong khoảng thời gian (phân theo ngày)
    public List<TimeBasedChartData> getDateRangeQuantitySoldData(LocalDate startDate, LocalDate endDate) {
        List<TimeBasedChartData> result = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String formattedDate = date.format(formatter);

            Integer quantitySold = orderService.getQuantitySoldByDate(date);

            result.add(new TimeBasedChartData(formattedDate, null, null, quantitySold));
        }

        return result;
    }

    // Lấy dữ liệu bán hàng theo danh mục trong khoảng thời gian
    public List<CategorySalesData> getDateRangeCategorySalesData(LocalDate startDate, LocalDate endDate) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.plusDays(1).atStartOfDay().minusNanos(1); // End of the day

        List<Order> orders = orderService.getOrdersBetweenDates(startDateTime, endDateTime);

        return calculateCategorySalesData(orders);
    }

    // Phương thức tổng hợp để lấy tất cả dữ liệu thống kê trong khoảng thời gian
    public StatisticsData getDateRangeStatisticsData(String startDateString, String endDateString) {
        LocalDate startDate;
        LocalDate endDate;

        if (startDateString == null || endDateString == null) {
            startDate = LocalDate.now().minusDays(1);
            endDate = LocalDate.now().plusDays(1);
        } else {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            startDate = LocalDate.parse(startDateString, formatter);
            endDate = LocalDate.parse(endDateString, formatter);
        }

        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("Start date must be before end date");
        }

        if (startDate.isEqual(endDate)) {
            startDate = startDate.minusDays(1);
            endDate = endDate.plusDays(1);
        }

        List<TimeBasedChartData> timeSeriesRevenueProfitData = getDateRangeRevenueAndProfitData(startDate, endDate);
        List<TimeBasedChartData> timeSeriesQuantityData = getDateRangeQuantitySoldData(startDate, endDate);
        List<CategorySalesData> categorySalesRatio = getDateRangeCategorySalesData(startDate, endDate);

        return new StatisticsData(timeSeriesRevenueProfitData, timeSeriesQuantityData, categorySalesRatio);
    }

    // ---------- End of DateRange ----------

    // ---------- Start of Weekly ----------

    // Lấy dữ liệu doanh thu và lợi nhuận theo tuần
    public List<TimeBasedChartData> getWeeklyRevenueAndProfitData() {
        List<TimeBasedChartData> result = new ArrayList<>();
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7 - 1);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String formattedDate = date.format(formatter);

            Double revenue = orderService.getRevenueByDate(date);
            Double profit = orderService.getProfitByDate(date);

            result.add(new TimeBasedChartData(formattedDate, revenue, profit, null));
        }

        return result;
    }

    // Lấy dữ liệu số lượng bán theo tuần
    public List<TimeBasedChartData> getWeeklyQuantitySoldData() {
        List<TimeBasedChartData> result = new ArrayList<>();
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7 - 1);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String formattedDate = date.format(formatter);

            Integer quantitySold = orderService.getQuantitySoldByDate(date);

            result.add(new TimeBasedChartData(formattedDate, null, null, quantitySold));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong tuần
    public List<CategorySalesData> getWeeklyCategorySalesData() {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7 - 1);

        List<CategorySalesData> result = new ArrayList<>();

        List<String> categories = productTypeService.getAllProductTypeNames();

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

    public StatisticsData getWeeklyStatisticsData() {
        List<TimeBasedChartData> timeSeriesRevenueProfitData = getWeeklyRevenueAndProfitData();
        List<TimeBasedChartData> timeSeriesQuantityData = getWeeklyQuantitySoldData();
        List<CategorySalesData> categorySalesRatio = getWeeklyCategorySalesData();

        return new StatisticsData(timeSeriesRevenueProfitData, timeSeriesQuantityData, categorySalesRatio);
    }

    // ---------- End of Weekly ----------

    // ---------- Start of Monthly ----------

    // Lấy dữ liệu doanh thu và lợi nhuận theo tháng
    public List<TimeBasedChartData> getMonthlyRevenueAndProfitData(int month, int year) {
        List<TimeBasedChartData> result = new ArrayList<>();
        YearMonth yearMonth = YearMonth.of(year, month);
        int daysInMonth = yearMonth.lengthOfMonth();

        for (int day = 1; day <= daysInMonth; day++) {
            LocalDate date = LocalDate.of(year, month, day);
            String formattedDate = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

            Double revenue = orderService.getRevenueByDate(date);
            Double profit = orderService.getProfitByDate(date);

            result.add(new TimeBasedChartData(formattedDate, revenue, profit, null));
        }

        return result;
    }

    // Lấy dữ liệu số lượng bán theo tháng
    public List<TimeBasedChartData> getMonthlyQuantitySoldData(int month, int year) {
        List<TimeBasedChartData> result = new ArrayList<>();
        YearMonth yearMonth = YearMonth.of(year, month);
        int daysInMonth = yearMonth.lengthOfMonth();

        for (int day = 1; day <= daysInMonth; day++) {
            LocalDate date = LocalDate.of(year, month, day);
            String formattedDate = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

            Integer quantitySold = orderService.getQuantitySoldByDate(date);

            result.add(new TimeBasedChartData(formattedDate, null, null, quantitySold));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong tháng
    public List<CategorySalesData> getMonthlyCategorySalesData(int month, int year) {
        LocalDateTime startOfMonth = LocalDate.of(year, month, 1).atStartOfDay();
        LocalDateTime endOfMonth = YearMonth.of(year, month).atEndOfMonth().plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderService.getOrdersBetweenDates(startOfMonth, endOfMonth);

        return calculateCategorySalesData(orders);
    }

    public StatisticsData getMonthlyStatisticsData(Integer month, Integer year) {
        if (month == null || year == null) {
            LocalDate now = LocalDate.now();
            month = now.getMonthValue();
            year = now.getYear();
        }

        List<TimeBasedChartData> timeSeriesRevenueProfitData = getMonthlyRevenueAndProfitData(month, year);
        List<TimeBasedChartData> timeSeriesQuantityData = getMonthlyQuantitySoldData(month, year);
        List<CategorySalesData> categorySalesRatio = getMonthlyCategorySalesData(month, year);

        return new StatisticsData(timeSeriesRevenueProfitData, timeSeriesQuantityData, categorySalesRatio);
    }

    // ---------- End of Monthly ----------

    // ---------- Start of Quarterly ----------

    // Lấy dữ liệu doanh thu và lợi nhuận theo quý
    public List<TimeBasedChartData> getQuarterlyRevenueAndProfitData(int quarter, int year) {
        List<TimeBasedChartData> result = new ArrayList<>();

        // Xác định tháng bắt đầu và kết thúc của quý
        int startMonth = (quarter - 1) * 3 + 1;
        int endMonth = startMonth + 2;

        for (int month = startMonth; month <= endMonth; month++) {
            YearMonth yearMonth = YearMonth.of(year, month);
            String formattedMonth = yearMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));

            // Tính tổng doanh thu và lợi nhuận trong tháng
            Double monthlyRevenue = 0.0;
            Double monthlyProfit = 0.0;

            for (int day = 1; day <= yearMonth.lengthOfMonth(); day++) {
                LocalDate date = LocalDate.of(year, month, day);
                monthlyRevenue += orderService.getRevenueByDate(date);
                monthlyProfit += orderService.getProfitByDate(date);
            }

            result.add(new TimeBasedChartData(formattedMonth, monthlyRevenue, monthlyProfit, null));
        }

        return result;
    }

    // Lấy dữ liệu số lượng bán theo quý
    public List<TimeBasedChartData> getQuarterlyQuantitySoldData(int quarter, int year) {
        List<TimeBasedChartData> result = new ArrayList<>();

        // Xác định tháng bắt đầu và kết thúc của quý
        int startMonth = (quarter - 1) * 3 + 1;
        int endMonth = startMonth + 2;

        for (int month = startMonth; month <= endMonth; month++) {
            YearMonth yearMonth = YearMonth.of(year, month);
            String formattedMonth = yearMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));

            // Tính tổng số lượng bán trong tháng
            Integer monthlyQuantity = 0;

            for (int day = 1; day <= yearMonth.lengthOfMonth(); day++) {
                LocalDate date = LocalDate.of(year, month, day);
                monthlyQuantity += orderService.getQuantitySoldByDate(date);
            }

            result.add(new TimeBasedChartData(formattedMonth, null, null, monthlyQuantity));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong quý
    public List<CategorySalesData> getQuarterlyCategorySalesData(int quarter, int year) {
        // Xác định tháng bắt đầu và kết thúc của quý
        int startMonth = (quarter - 1) * 3 + 1;
        int endMonth = startMonth + 2;

        LocalDateTime startOfQuarter = LocalDate.of(year, startMonth, 1).atStartOfDay();
        LocalDateTime endOfQuarter = YearMonth.of(year, endMonth).atEndOfMonth().plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderService.getOrdersBetweenDates(startOfQuarter, endOfQuarter);

        return calculateCategorySalesData(orders);
    }

    public StatisticsData getQuarterlyStatisticsData(Integer quarter, Integer year) {
        if (quarter == null || year == null) {
            int month = LocalDate.now().getMonthValue();
            quarter = (month - 1) / 3 + 1;
            year = LocalDate.now().getYear();
        }

        List<TimeBasedChartData> timeSeriesRevenueProfitData = getQuarterlyRevenueAndProfitData(quarter, year);
        List<TimeBasedChartData> timeSeriesQuantityData = getQuarterlyQuantitySoldData(quarter, year);
        List<CategorySalesData> categorySalesRatio = getQuarterlyCategorySalesData(quarter, year);

        return new StatisticsData(timeSeriesRevenueProfitData, timeSeriesQuantityData, categorySalesRatio);
    }

    // ---------- End of Quarterly ----------

    // ---------- Start of Yearly ----------

    // Lấy dữ liệu doanh thu và lợi nhuận theo năm
    public List<TimeBasedChartData> getYearlyRevenueAndProfitData(int year) {
        List<TimeBasedChartData> result = new ArrayList<>();

        for (int month = 1; month <= 12; month++) {
            YearMonth yearMonth = YearMonth.of(year, month);
            String formattedMonth = yearMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));

            // Tính tổng doanh thu và lợi nhuận trong tháng
            Double monthlyRevenue = 0.0;
            Double monthlyProfit = 0.0;

            for (int day = 1; day <= yearMonth.lengthOfMonth(); day++) {
                LocalDate date = LocalDate.of(year, month, day);
                monthlyRevenue += orderService.getRevenueByDate(date);
                monthlyProfit += orderService.getProfitByDate(date);
            }

            result.add(new TimeBasedChartData(formattedMonth, monthlyRevenue, monthlyProfit, null));
        }

        return result;
    }

    // Lấy dữ liệu số lượng bán theo năm
    public List<TimeBasedChartData> getYearlyQuantitySoldData(int year) {
        List<TimeBasedChartData> result = new ArrayList<>();

        for (int month = 1; month <= 12; month++) {
            YearMonth yearMonth = YearMonth.of(year, month);
            String formattedMonth = yearMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));

            // Tính tổng số lượng bán trong tháng
            Integer monthlyQuantity = 0;

            for (int day = 1; day <= yearMonth.lengthOfMonth(); day++) {
                LocalDate date = LocalDate.of(year, month, day);
                monthlyQuantity += orderService.getQuantitySoldByDate(date);
            }

            result.add(new TimeBasedChartData(formattedMonth, null, null, monthlyQuantity));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong năm
    public List<CategorySalesData> getYearlyCategorySalesData(int year) {
        LocalDateTime startOfYear = LocalDate.of(year, 1, 1).atStartOfDay();
        LocalDateTime endOfYear = LocalDate.of(year, 12, 31).plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderService.getOrdersBetweenDates(startOfYear, endOfYear);

        return calculateCategorySalesData(orders);
    }

    public StatisticsData getYearlyStatisticsData(Integer year) {
        if (year == null) {
            year = LocalDate.now().getYear();
        }

        List<TimeBasedChartData> timeSeriesRevenueProfitData = getYearlyRevenueAndProfitData(year);
        List<TimeBasedChartData> timeSeriesQuantityData = getYearlyQuantitySoldData(year);
        List<CategorySalesData> categorySalesRatio = getYearlyCategorySalesData(year);

        return new StatisticsData(timeSeriesRevenueProfitData, timeSeriesQuantityData, categorySalesRatio);
    }

    // ---------- End of Yearly ----------

    // Phương thức hỗ trợ để tính toán dữ liệu bán theo danh mục
    private List<CategorySalesData> calculateCategorySalesData(List<Order> orders) {
        Map<String, Integer> categorySales = new HashMap<>();
        final String UNKNOWN_CATEGORY = "Unknown"; // Danh mục mặc định khi không xác định được

        // Tính tổng số lượng bán cho mỗi danh mục
        for (Order order : orders) {
            for (OrderItem item : order.getItems()) {
                // Lấy thông tin sản phẩm
                String productId = item.getProductId();
                int quantity = item.getQuantity();

                // Xử lý khi danh mục trả về null
                String category = productService.getProductTypeNameById(productId);

                // Kiểm tra null và xử lý
                if (category == null) {
                    // Thử thay thế bằng cách lấy sản phẩm trực tiếp (nếu có thể)
                    try {
                        Product product = productService.getProductById(productId);
                        if (product != null && product.getProductType() != null) {
                            category = product.getProductType().getName(); // Giả sử Product có getType() trả về đối tượng có getName()
                        } else {
                            logger.warn("Không tìm thấy sản phẩm hoặc loại sản phẩm cho ID: {}", productId);
                            category = UNKNOWN_CATEGORY;
                        }
                    } catch (Exception e) {
                        logger.error("Lỗi khi lấy thông tin sản phẩm cho ID: {}", productId, e);
                        category = UNKNOWN_CATEGORY;
                    }
                }

                // Cập nhật dữ liệu bán hàng theo danh mục
                categorySales.put(category, categorySales.getOrDefault(category, 0) + quantity);
            }
        }

        return categorySales.entrySet().stream()
                .map(entry -> new CategorySalesData(entry.getKey(), entry.getValue()))
                .collect(Collectors.toList());
    }
}
