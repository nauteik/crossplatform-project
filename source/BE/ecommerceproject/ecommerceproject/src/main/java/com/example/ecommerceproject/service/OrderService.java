package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import com.example.ecommerceproject.repository.CartRepository;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import com.example.ecommerceproject.repository.UserRepository;
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
import java.util.Optional;

/**
 * Service for managing orders
 */
@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CartService cartService;

    @Autowired
    private ProductService productService;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private UserRepository userRepository;

    /**
     * Create a new order from cart items
     */
    public Order createOrder(String userId, Address shippingAddress, String paymentMethod, List<String> selectedItemIds) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Cart not found for user: " + userId));

        List<CartItem> cartItems;
        if (selectedItemIds != null && !selectedItemIds.isEmpty()) {
            // Filter cart items based on selected item IDs
            cartItems = cart.getItems().stream()
                    .filter(item -> selectedItemIds.contains(item.getProductId()))
                    .collect(Collectors.toList());
            if (cartItems.isEmpty()) {
                throw new IllegalArgumentException("No selected items found in cart");
            }
        } else {
            cartItems = cart.getItems();
            if (cartItems.isEmpty()) {
                throw new IllegalArgumentException("Cart is empty");
            }
        }

        // Convert cart items to order items
        List<OrderItem> orderItems = cartItems.stream().map(cartItem -> {
            Product product = productRepository.findById(cartItem.getProductId())
                    .orElseThrow(() -> new IllegalArgumentException("Product not found: " + cartItem.getProductId()));

            OrderItem orderItem = new OrderItem();
            orderItem.setProductId(cartItem.getProductId());
            orderItem.setProductName(product.getName());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setPrice(product.getPrice());
            orderItem.setImageUrl(product.getPrimaryImageUrl());
            return orderItem;
        }).collect(Collectors.toList());

        // Calculate total amount
        double totalAmount = orderItems.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();

        // Create new order
        Order order = new Order(userId, orderItems, totalAmount, OrderStatus.PENDING, paymentMethod, shippingAddress);
        return orderRepository.save(order);
    }

    /**
     * Get order by ID
     */
    public Order getOrderById(String orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found with id: " + orderId));
    }

    /**
     * Get all orders for a user
     */
    public List<Order> getOrdersByUserId(String userId) {
        return orderRepository.findByUserId(userId);
    }

    /**
     * Process order payment
     */
    public Order processOrderPayment(String orderId, Map<String, Object> paymentDetails) {
        Order order = getOrderById(orderId);

        // Validate order status
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException("Cannot process payment for order with status: " + order.getStatus());
        }

        // Process payment based on payment method
        boolean paymentSuccess = processPaymentByMethod(order.getPaymentMethod(), paymentDetails, order.getTotalAmount());

        // Update order status based on payment result
        if (paymentSuccess) {
            order.updateStatus(OrderStatus.PAID);
        } else {
            order.updateStatus(OrderStatus.FAILED);
        }

        return orderRepository.save(order);
    }

    private boolean processPaymentByMethod(String paymentMethod, Map<String, Object> paymentDetails, double amount) {
        // In a real application, this would integrate with payment gateways
        // For demo purposes, we'll simulate successful payments
        return true;
    }

    /**
     * Get all orders (for admin)
     */
    public List<Order> getAllOrders() {
        List<Order> orders = orderRepository.findAll();
        
        // Thêm thông tin user (email và username) vào response
        for (Order order : orders) {
            try {
                Optional<User> userOpt = userRepository.findById(order.getUserId());
                if (userOpt.isPresent()) {
                    User user = userOpt.get();
                    
                    // Thêm thông tin dưới dạng thuộc tính bổ sung vào order
                    Map<String, Object> additionalInfo = new HashMap<>();
                    additionalInfo.put("userEmail", user.getEmail());
                    additionalInfo.put("username", user.getUsername());
                    
                    // Lưu vào order (giả định đã có phương thức setAdditionalInfo trong Order)
                    order.setAdditionalInfo(additionalInfo);
                }
            } catch (Exception e) {
                logger.error("Error fetching user info for order: {}", order.getId(), e);
            }
        }
        
        return orders;
    }

    /**
     * Update order status
     */
    public Order updateOrderStatus(String orderId, OrderStatus newStatus) {
        Order order = getOrderById(orderId);
        order.updateStatus(newStatus);
        return orderRepository.save(order);
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

    public List<Order> getOrdersBetweenDates(LocalDateTime startDateTime, LocalDateTime endDateTime) {
        return orderRepository.findByCreatedAtBetween(startDateTime, endDateTime);
    }
}