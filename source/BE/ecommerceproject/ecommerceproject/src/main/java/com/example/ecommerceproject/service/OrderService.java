package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import com.example.ecommerceproject.repository.CartRepository;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import com.example.ecommerceproject.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
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
    
    @Autowired
    private CouponService couponService;
    
    @Autowired
    private UserService userService;

    @Autowired
    private ApplicationContext applicationContext;

    /**
     * Create a new order from cart items
     */
    public Order createOrder(String userId, Address shippingAddress, String paymentMethod, List<String> selectedItemIds) {
        if (selectedItemIds == null || selectedItemIds.isEmpty()) {
            throw new IllegalArgumentException("Không có sản phẩm nào được chọn để thanh toán");
        }

        // Tạo danh sách OrderItems trực tiếp từ selectedItemIds
        List<OrderItem> orderItems = new ArrayList<>();
        
        for (String productId : selectedItemIds) {
            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm: " + productId));
            
            OrderItem orderItem = new OrderItem();
            orderItem.setProductId(productId);
            orderItem.setProductName(product.getName());
            orderItem.setQuantity(1); // Mặc định số lượng là 1, có thể điều chỉnh sau
            orderItem.setPrice(product.getPrice());
            orderItem.setImageUrl(product.getPrimaryImageUrl());
            
            orderItems.add(orderItem);
        }

        // Calculate total amount
        double totalAmount = orderItems.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();

        // Create new order
        Order order = new Order(userId, orderItems, totalAmount, OrderStatus.PENDING, paymentMethod, shippingAddress);
        Order savedOrder = orderRepository.save(order);
        
        // Gửi email thông báo đơn hàng thành công
        sendOrderConfirmationEmail(savedOrder);
        
        return savedOrder;
    }
    
    /**
     * Create a new order from cart items with coupon applied
     */
    public Order createOrderWithCoupon(String userId, Address shippingAddress, String paymentMethod, 
                                      List<String> selectedItemIds, String couponCode) {
        // First create the order normally
        Order order = createOrder(userId, shippingAddress, paymentMethod, selectedItemIds);
        
        // Apply coupon if provided
        if (couponCode != null && !couponCode.isEmpty()) {
            order = applyCouponToOrder(order.getId(), couponCode);
            // Gửi email lại sau khi áp dụng coupon
            sendOrderConfirmationEmail(order);
        }
        
        return order;
    }
    
    /**
     * Create a new order with loyalty points applied
     */
    public Order createOrderWithLoyaltyPoints(String userId, Address shippingAddress, String paymentMethod, 
                                      List<String> selectedItemIds, int loyaltyPointsToUse) {
        // First create the order normally
        Order order = createOrder(userId, shippingAddress, paymentMethod, selectedItemIds);
        
        // Apply loyalty points if provided
        if (loyaltyPointsToUse > 0) {
            order = applyLoyaltyPointsToOrder(order.getId(), loyaltyPointsToUse);
            // Gửi email lại sau khi áp dụng loyalty points
            sendOrderConfirmationEmail(order);
        }
        
        return order;
    }
    
    /**
     * Create an order with both coupon and loyalty points
     */
    public Order createOrderWithCouponAndLoyaltyPoints(String userId, Address shippingAddress, String paymentMethod, 
                                      List<String> selectedItemIds, String couponCode, int loyaltyPointsToUse) {
        // First create the order normally
        Order order = createOrder(userId, shippingAddress, paymentMethod, selectedItemIds);
        
        // Apply coupon if provided
        if (couponCode != null && !couponCode.isEmpty()) {
            order = applyCouponToOrder(order.getId(), couponCode);
        }
        
        // Apply loyalty points if provided
        if (loyaltyPointsToUse > 0) {
            order = applyLoyaltyPointsToOrder(order.getId(), loyaltyPointsToUse);
        }
        
        // Gửi email sau khi áp dụng tất cả giảm giá
        sendOrderConfirmationEmail(order);
        
        return order;
    }
    
    /**
     * Apply loyalty points to an existing order
     */
    public Order applyLoyaltyPointsToOrder(String orderId, int pointsToUse) {
        Order order = getOrderById(orderId);
        
        // Check if order already has loyalty points applied
        if (order.getLoyaltyPointsUsed() > 0) {
            throw new IllegalArgumentException("Order already has loyalty points applied");
        }
        
        try {
            // Calculate discount amount (1 point = 1000 VND)
            double discountAmount = userService.useLoyaltyPoints(order.getUserId(), pointsToUse);
            
            // Apply loyalty points to order
            order.applyLoyaltyPoints(pointsToUse, discountAmount);
            
            // Save and return updated order
            return orderRepository.save(order);
            
        } catch (Exception e) {
            throw new IllegalArgumentException("Error applying loyalty points: " + e.getMessage());
        }
    }
    
    /**
     * Apply coupon to an existing order
     */
    public Order applyCouponToOrder(String orderId, String couponCode) {
        Order order = getOrderById(orderId);
        
        // Check if order already has a coupon
        if (order.getCouponCode() != null && !order.getCouponCode().isEmpty()) {
            throw new IllegalArgumentException("Order already has a coupon applied");
        }
        
        try {
            // Validate and get coupon details
            Map<String, Object> couponDetails = couponService.getCouponDetails(couponCode);
            
            if (!(Boolean) couponDetails.get("valid")) {
                throw new IllegalArgumentException("Coupon is not valid");
            }
            
            // Get coupon value
            double couponValue;
            Object rawValue = couponDetails.get("value");
            if (rawValue instanceof Integer) {
                couponValue = ((Integer) rawValue).doubleValue();
            } else if (rawValue instanceof Double) {
                couponValue = (Double) rawValue;
            } else {
                couponValue = 0.0;
            }
            
            // Apply coupon to order
            boolean applied = couponService.applyCouponToOrder(couponCode, orderId);
            
            if (!applied) {
                throw new IllegalArgumentException("Failed to apply coupon to order");
            }
            
            // Apply discount to order
            order.applyCoupon(couponCode, couponValue);
            
            // Save and return updated order
            return orderRepository.save(order);
            
        } catch (Exception e) {
            throw new IllegalArgumentException("Error applying coupon: " + e.getMessage());
        }
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
        boolean paymentSuccess = processPaymentByMethod(order.getPaymentMethod(), paymentDetails, order.getFinalAmount());

        // Update order status based on payment result
        if (paymentSuccess) {
            // Kiểm tra nếu phương thức thanh toán là COD thì không tự động cập nhật trạng thái
            // COD orders will remain in PENDING status until manually updated by staff
            if (!"COD".equals(order.getPaymentMethod())) {
                order.updateStatus(OrderStatus.PAID);
                
                // Add loyalty points to user after successful payment
                int pointsEarned = order.calculateLoyaltyPointsEarned();
                userService.addLoyaltyPoints(order.getUserId(), order.getFinalAmount());
            } else {
                // Với COD, chỉ cập nhật thời gian và không thay đổi trạng thái
                logger.info("COD order {} confirmed but status remains PENDING until payment is received", order.getId());
                order.setUpdatedAt(LocalDateTime.now());
                
                // Không cộng điểm loyalty cho đơn COD cho đến khi được xác nhận thanh toán
            }
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
        
        // Sắp xếp đơn hàng theo thời gian tạo giảm dần (mới nhất trước)
        orders.sort((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()));
        
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

    /**
     * Gửi email xác nhận đơn hàng
     */
    private void sendOrderConfirmationEmail(Order order) {
        try {
            // Lấy thông tin user để lấy email
            User user = userRepository.findById(order.getUserId())
                    .orElse(null);
            
            if (user != null && user.getEmail() != null) {
                // Chuẩn bị thông tin cho email
                Map<String, Object> emailData = new HashMap<>();
                emailData.put("to", user.getEmail());
                emailData.put("customerName", user.getName() != null ? user.getName() : user.getUsername());
                emailData.put("orderId", order.getId());
                emailData.put("totalAmount", order.getTotalAmount());
                emailData.put("orderItems", order.getItems());
                emailData.put("paymentMethod", order.getPaymentMethod());
                emailData.put("shippingAddress", order.getShippingAddress());
                
                // Thêm thông tin coupon nếu có
                if (order.getCouponCode() != null && !order.getCouponCode().isEmpty()) {
                    emailData.put("couponCode", order.getCouponCode());
                    emailData.put("couponDiscount", order.getCouponDiscount());
                    emailData.put("finalAmount", order.getFinalAmount());
                    emailData.put("hasCoupon", true);
                } else {
                    emailData.put("hasCoupon", false);
                }
                
                // Gửi email
                EmailService emailService = applicationContext.getBean(EmailService.class);
                emailService.sendOrderConfirmationEmail(emailData);
            } else {
                logger.warn("User email not found for order: {}", order.getId());
            }
        } catch (Exception e) {
            logger.error("Error sending order confirmation email: {}", e.getMessage());
        }
    }
}