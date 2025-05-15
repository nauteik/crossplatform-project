package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

/**
 * Service for managing orders
 */
@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private CartService cartService;

    @Autowired
    private ProductService productService;

    @Autowired
    private PaymentService paymentService;
    @Autowired
    private ProductRepository productRepository;

    /**
     * Create a new order with PENDING status
     *
     * @param userId User ID
     * @param shippingAddress Shipping address
     * @param paymentMethod Payment method (must be supported by PaymentService)
     * @param selectedItemIds Optional list of specific cart item IDs to include in the order
     * @return The created order
     * @throws IllegalArgumentException if cart is empty or products are unavailable
     */
    @Transactional
    public Order createOrder(String userId, String shippingAddress, String paymentMethod, List<String> selectedItemIds) {
        // Validate payment method is supported
        if (!paymentService.getSupportedPaymentMethods().contains(paymentMethod)) {
            throw new IllegalArgumentException("Unsupported payment method: " + paymentMethod);
        }

        // Get user's cart
        Cart cart = cartService.getCartByUserId(userId);
        if (cart.getItems().isEmpty()) {
            throw new IllegalArgumentException("Cannot create order with empty cart");
        }

        // Filter items if selectedItemIds is provided
        List<CartItem> itemsToOrder = cart.getItems();
        if (selectedItemIds != null && !selectedItemIds.isEmpty()) {
            logger.info("Creating order with selected items only. User: {}, Selected item count: {}",
                    userId, selectedItemIds.size());

            itemsToOrder = cart.getItems().stream()
                    .filter(item -> selectedItemIds.contains(item.getProductId()))
                    .collect(Collectors.toList());

            if (itemsToOrder.isEmpty()) {
                throw new IllegalArgumentException("None of the selected items were found in the cart");
            }
        }

        // Convert CartItems to OrderItems and check product availability
        List<OrderItem> orderItems = new ArrayList<>();
        double totalAmount = 0.0;

        for (CartItem cartItem : itemsToOrder) {
            // Check product availability/quantity
            Product product = productService.getProductById(cartItem.getProductId());

            if (product == null) {
                throw new IllegalArgumentException("Product not found: " + cartItem.getProductId());
            }

            if (product.getQuantity() < cartItem.getQuantity()) {
                throw new IllegalArgumentException("Not enough stock for product: " + product.getName());
            }

            // Decrease product quantity
            productService.decreaseQuantity(cartItem.getProductId(), cartItem.getQuantity());

            // Add to order items
            OrderItem orderItem = new OrderItem(
                    cartItem.getProductId(),
                    cartItem.getProductName(),
                    cartItem.getQuantity(),
                    cartItem.getPrice(),
                    cartItem.getImageUrl()
            );
            orderItems.add(orderItem);

            // Calculate total amount
            totalAmount += cartItem.getPrice() * cartItem.getQuantity();
        }

        // Create order with PENDING status
        Order order = new Order();
        order.setUserId(userId);
        order.setItems(orderItems);
        order.setTotalAmount(totalAmount);
        order.setStatus(OrderStatus.PENDING);
        order.setPaymentMethod(paymentMethod);
        order.setShippingAddress(shippingAddress);
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        // Save the order
        Order savedOrder = orderRepository.save(order);
        logger.info("Created order: {} with status: {} for user: {}",
                savedOrder.getId(), savedOrder.getStatus(), savedOrder.getUserId());

        return savedOrder;
    }

    /**
     * Process payment for an existing order
     *
     * @param orderId Order ID
     * @param paymentDetails Payment details (depends on payment method)
     * @return The updated order
     * @throws IllegalArgumentException if order not found or not in PENDING status
     */
    @Transactional
    public Order processOrderPayment(String orderId, Map<String, Object> paymentDetails) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException("Cannot process payment for order with status: " + order.getStatus());
        }

        // Process the payment through PaymentService
        boolean paymentSuccess = paymentService.processPayment(order, paymentDetails);

        // Update order status based on payment result
        if (paymentSuccess) {
            order.updateStatus(OrderStatus.PAID);
            logger.info("Payment successful for order: {}, updating status to: {}",
                    order.getId(), order.getStatus());

            List<String> productIds = order.getItems().stream()
                    .map(OrderItem::getProductId)
                    .collect(Collectors.toList());

            cartService.removeItemsFromCart(order.getUserId(), productIds);
            logger.info("Removed {} items from cart for user: {} after successful payment",
                    productIds.size(), order.getUserId());
        } else {
            order.updateStatus(OrderStatus.FAILED);
            logger.warn("Payment failed for order: {}, updating status to: {}",
                    order.getId(), order.getStatus());

            // Restore product quantities if payment fails
            restoreProductQuantities(order);
        }

        // Save the updated order
        Order updatedOrder = orderRepository.save(order);
        return updatedOrder;
    }

    /**
     * Restore product quantities for failed orders
     */
    private void restoreProductQuantities(Order order) {
        for (OrderItem item : order.getItems()) {
            productService.increaseQuantity(item.getProductId(), item.getQuantity());
            logger.info("Restored {} units of product: {} after failed payment",
                    item.getQuantity(), item.getProductId());
        }
    }

    /**
     * Update the status of an order
     *
     * @param orderId Order ID
     * @param newStatus New order status
     * @return The updated order
     * @throws IllegalArgumentException if order not found
     */
    @Transactional
    public Order updateOrderStatus(String orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        order.updateStatus(newStatus);
        logger.info("Updated order: {} status from: {} to: {}",
                order.getId(), order.getStatus(), newStatus);

        return orderRepository.save(order);
    }

    /**
     * Get an order by ID
     *
     * @param orderId Order ID
     * @return The order
     * @throws IllegalArgumentException if order not found
     */
    public Order getOrderById(String orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
    }

    /**
     * Get all orders for a user
     *
     * @param userId User ID
     * @return List of orders
     */
    public List<Order> getOrdersByUserId(String userId) {
        return orderRepository.findByUserId(userId);
    }

    /**
     * Get all orders
     *
     * @return List of all orders in the system
     */
    public List<Order> getAllOrders() {
        logger.info("Retrieving all orders");
        return orderRepository.findAll();
    }

    public int getOrderCount() {
        return (int) orderRepository.count();
    }

    // Lấy doanh thu theo ngày
    public Double getRevenueByDate(LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderRepository.findByCreatedAtBetween(startOfDay, endOfDay);

        return orders.stream()
                .mapToDouble(Order::getTotalAmount)
                .sum();
    }

    // Lấy lợi nhuận theo ngày
    public Double getProfitByDate(LocalDate date) {
        Double revenue = getRevenueByDate(date);
        return revenue * 0.2; // Giả sử lợi nhuận là 20% doanh thu
    }

    // Lấy số lượng sản phẩm đã bán theo ngày
    public Integer getQuantitySoldByDate(LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderRepository.findByCreatedAtBetween(startOfDay, endOfDay);

        return orders.stream()
                .flatMap(order -> order.getItems().stream())
                .mapToInt(OrderItem::getQuantity)
                .sum();
    }

    // Lấy số lượng sản phẩm đã bán theo danh mục
    public int getQuantitySoldByCategory(String category) {
        List<Order> allOrders = orderRepository.findAll();

        for (Order order : allOrders) {
            System.out.println(order);
        }

        return allOrders.stream()
                .flatMap(order -> order.getItems().stream())
                .filter(item -> category.equals(productService.getProductTypeNameById(item.getProductId())))
                .mapToInt(OrderItem::getQuantity)
                .sum();
    }

    // Lấy dữ liệu doanh thu và lợi nhuận theo tháng
    public List<TimeBasedChartData> getMonthlyRevenueAndProfitData(int month, int year) {
        List<TimeBasedChartData> result = new ArrayList<>();
        YearMonth yearMonth = YearMonth.of(year, month);
        int daysInMonth = yearMonth.lengthOfMonth();

        for (int day = 1; day <= daysInMonth; day++) {
            LocalDate date = LocalDate.of(year, month, day);
            String formattedDate = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

            Double revenue = getRevenueByDate(date);
            Double profit = getProfitByDate(date);

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

            Integer quantitySold = getQuantitySoldByDate(date);

            result.add(new TimeBasedChartData(formattedDate, null, null, quantitySold));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong tháng
    public List<CategorySalesData> getCategorySalesDataByMonth(int month, int year) {
        LocalDateTime startOfMonth = LocalDate.of(year, month, 1).atStartOfDay();
        LocalDateTime endOfMonth = YearMonth.of(year, month).atEndOfMonth().plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderRepository.findByCreatedAtBetween(startOfMonth, endOfMonth);

        return calculateCategorySalesData(orders);
    }

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
                monthlyRevenue += getRevenueByDate(date);
                monthlyProfit += getProfitByDate(date);
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
                monthlyQuantity += getQuantitySoldByDate(date);
            }

            result.add(new TimeBasedChartData(formattedMonth, null, null, monthlyQuantity));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong quý
    public List<CategorySalesData> getCategorySalesDataByQuarter(int quarter, int year) {
        // Xác định tháng bắt đầu và kết thúc của quý
        int startMonth = (quarter - 1) * 3 + 1;
        int endMonth = startMonth + 2;

        LocalDateTime startOfQuarter = LocalDate.of(year, startMonth, 1).atStartOfDay();
        LocalDateTime endOfQuarter = YearMonth.of(year, endMonth).atEndOfMonth().plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderRepository.findByCreatedAtBetween(startOfQuarter, endOfQuarter);

        return calculateCategorySalesData(orders);
    }

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
                monthlyRevenue += getRevenueByDate(date);
                monthlyProfit += getProfitByDate(date);
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
                monthlyQuantity += getQuantitySoldByDate(date);
            }

            result.add(new TimeBasedChartData(formattedMonth, null, null, monthlyQuantity));
        }

        return result;
    }

    // Lấy dữ liệu bán theo danh mục trong năm
    public List<CategorySalesData> getCategorySalesDataByYear(int year) {
        LocalDateTime startOfYear = LocalDate.of(year, 1, 1).atStartOfDay();
        LocalDateTime endOfYear = LocalDate.of(year, 12, 31).plusDays(1).atStartOfDay().minusNanos(1);

        List<Order> orders = orderRepository.findByCreatedAtBetween(startOfYear, endOfYear);

        return calculateCategorySalesData(orders);
    }

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
                        Product product = productRepository.findById(productId).orElse(null);
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

        // Chuyển đổi từ Map sang List<CategorySalesData>
        return categorySales.entrySet().stream()
                .map(entry -> new CategorySalesData(entry.getKey(), entry.getValue()))
                .collect(Collectors.toList());
    }

    public List<Order> getOrdersCreatedOnDate(LocalDate date) {
        // Get start and end of the specified date
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(23, 59, 59);

        // Filter orders from the repository by creation date
        return orderRepository.findByCreatedAtBetween(startOfDay, endOfDay);
    }

    public List<Order> getOrdersCreatedBetweenDates(LocalDate startDate, LocalDate endDate) {
        // Convert to LocalDateTime to include the full time range
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        return orderRepository.findByCreatedAtBetween(startDateTime, endDateTime);
    }
}