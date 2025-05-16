package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Address;
import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.OrderService;
import com.example.ecommerceproject.service.OrderStateManager;
import com.example.ecommerceproject.service.PaymentService;
import com.example.ecommerceproject.service.UserService;
import com.example.ecommerceproject.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.HashMap;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin("*")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private OrderStateManager orderStateManager;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private EmailService emailService;

    /**
     * Create a new order with PENDING status
     */
    @PostMapping("/create")
    public ResponseEntity<ApiResponse<?>> createOrder(
            @RequestBody Map<String, Object> orderRequest) {
        try {
            String userId = (String) orderRequest.get("userId");
            boolean isGuestCheckout = userId == null || userId.trim().isEmpty();
            
            // Xử lý thanh toán cho khách không đăng nhập
            if (isGuestCheckout) {
                Map<String, Object> userInfo = (Map<String, Object>) orderRequest.get("userInfo");
                if (userInfo == null) {
                    return ResponseEntity.badRequest().body(
                            new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                    "Missing user information for guest checkout", null));
                }
                
                String email = (String) userInfo.get("email");
                String fullName = (String) userInfo.get("fullName");
                String phoneNumber = (String) userInfo.get("phoneNumber");
                
                // Kiểm tra xem email đã tồn tại chưa
                User existingUser = userService.findByEmail(email);
                if (existingUser != null) {
                    return ResponseEntity.badRequest().body(
                            new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                    "Email đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.", null));
                }
                
                // Tạo mật khẩu ngẫu nhiên cho người dùng mới
                String password = generateRandomPassword();
                
                // Tạo người dùng mới
                User newUser = userService.createUser(email, password, fullName);
                userId = newUser.getId();
                
                // Tạo địa chỉ mới
                Map<String, Object> addressInfo = (Map<String, Object>) orderRequest.get("addressInfo");
                if (addressInfo == null) {
                    return ResponseEntity.badRequest().body(
                            new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                    "Missing address information for guest checkout", null));
                }
                
                Address newAddress = new Address();
                newAddress.setId(UUID.randomUUID().toString());
                newAddress.setFullName(fullName);
                newAddress.setPhoneNumber(phoneNumber);
                newAddress.setAddressLine((String) addressInfo.get("addressLine"));
                newAddress.setCity((String) addressInfo.get("city"));
                newAddress.setDistrict((String) addressInfo.get("district"));
                newAddress.setWard((String) addressInfo.get("ward"));
                newAddress.setDefault(true);
                
                // Lưu địa chỉ vào người dùng
                userService.addAddress(userId, newAddress);
                
                // Gửi email thông báo tài khoản mới
                Map<String, Object> emailData = new HashMap<>();
                emailData.put("to", email);
                emailData.put("subject", "Tài khoản mới đã được tạo");
                emailData.put("username", email);
                emailData.put("password", password);
                emailService.sendAccountCreationEmail(emailData);
                
                // Cập nhật thông tin đơn hàng với địa chỉ mới
                orderRequest.put("shippingAddress", newAddress);
            } else {
                // Xử lý cho người dùng đã đăng nhập
                Address shippingAddress = (Address) orderRequest.get("shippingAddress");
                if (shippingAddress == null) {
                    String addressId = (String) orderRequest.get("addressId");
                    if (addressId != null) {
                        // Lấy địa chỉ từ addressId
                        shippingAddress = userService.getAddressById(userId, addressId);
                    }
                    
                    if (shippingAddress == null) {
                        return ResponseEntity.badRequest().body(
                                new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                        "Missing shipping address information", null));
                    }
                }
                
                orderRequest.put("shippingAddress", shippingAddress);
            }
            
            String paymentMethod = (String) orderRequest.get("paymentMethod");

            // Get selectedItemIds from the request - handle potential null or type conversion
            List<String> selectedItemIds = null;
            Object selectedItemIdsObj = orderRequest.get("selectedItemIds");
            if (selectedItemIdsObj instanceof List) {
                selectedItemIds = (List<String>) selectedItemIdsObj;
            }

            if (userId == null || paymentMethod == null) {
                return ResponseEntity.badRequest().body(
                        new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                "Missing required fields: userId or paymentMethod", null));
            }

            Order order = orderService.createOrder(userId, 
                                (Address) orderRequest.get("shippingAddress"), 
                                paymentMethod, 
                                selectedItemIds);

            // Thêm thông tin đăng nhập cho khách hàng nếu là guest checkout
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("order", order);
            if (isGuestCheckout) {
                String token = userService.generateAuthToken(userId);
                responseData.put("token", token);
                responseData.put("userId", userId);
                responseData.put("message", "Tài khoản đã được tạo tự động. Vui lòng kiểm tra email để xem mật khẩu của bạn.");
            }

            return ResponseEntity.status(HttpStatus.CREATED).body(
                    new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                            "Order created successfully", responseData));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error creating order: " + e.getMessage(), null));
        }
    }

    /**
     * Hàm tạo mật khẩu ngẫu nhiên
     */
    private String generateRandomPassword() {
        String upperAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lowerAlphabet = "abcdefghijklmnopqrstuvwxyz";
        String numbers = "0123456789";
        String specialChars = "!@#$%^&*()_-+=<>?";
        
        String allChars = upperAlphabet + lowerAlphabet + numbers + specialChars;
        StringBuilder password = new StringBuilder();
        
        // Đảm bảo password có ít nhất 8 ký tự
        for (int i = 0; i < 8; i++) {
            int index = (int) (Math.random() * allChars.length());
            password.append(allChars.charAt(index));
        }
        
        return password.toString();
    }

    /**
     * Process payment for an existing order
     */
    @PostMapping("/{orderId}/pay")
    public ResponseEntity<ApiResponse<?>> processPayment(
            @PathVariable String orderId,
            @RequestBody Map<String, Object> paymentDetails) {
        try {
            Order updatedOrder = orderService.processOrderPayment(orderId, paymentDetails);

            String message = updatedOrder.getStatus() == OrderStatus.PAID ?
                    "Payment successful" : "Payment failed";

            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    message, updatedOrder));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error processing payment: " + e.getMessage(), null));
        }
    }

    /**
     * Process an order to its next state using State Pattern
     */
    @PostMapping("/{orderId}/process")
    public ResponseEntity<ApiResponse<?>> processOrder(@PathVariable String orderId) {
        try {
            boolean success = orderStateManager.processOrder(orderId);
            Order order = orderService.getOrderById(orderId);

            if (success) {
                return ResponseEntity.ok(new ApiResponse<>(
                        ApiStatus.SUCCESS.getCode(),
                        "Order processed successfully to state: " + order.getStatus(),
                        order
                ));
            } else {
                return ResponseEntity.ok(new ApiResponse<>(
                        ApiStatus.BAD_REQUEST.getCode(),
                        "Cannot process order from current state: " + order.getStatus(),
                        order
                ));
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error processing order: " + e.getMessage(), null));
        }
    }

    /**
     * Cancel an order using State Pattern
     */
    @PostMapping("/{orderId}/cancel")
    public ResponseEntity<ApiResponse<?>> cancelOrder(@PathVariable String orderId) {
        try {
            boolean success = orderStateManager.cancelOrder(orderId);
            Order order = orderService.getOrderById(orderId);

            if (success) {
                return ResponseEntity.ok(new ApiResponse<>(
                        ApiStatus.SUCCESS.getCode(),
                        "Order cancelled successfully",
                        order
                ));
            } else {
                return ResponseEntity.ok(new ApiResponse<>(
                        ApiStatus.BAD_REQUEST.getCode(),
                        "Cannot cancel order from current state: " + order.getStatus(),
                        order
                ));
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error cancelling order: " + e.getMessage(), null));
        }
    }

    /**
     * Get order by ID
     */
    @GetMapping("/{orderId}")
    public ResponseEntity<ApiResponse<?>> getOrderById(@PathVariable String orderId) {
        try {
            Order order = orderService.getOrderById(orderId);
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    "Order retrieved successfully", order));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error retrieving order: " + e.getMessage(), null));
        }
    }

    /**
     * Get all orders for a user
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<?>> getOrdersByUser(@PathVariable String userId) {
        try {
            List<Order> orders = orderService.getOrdersByUserId(userId);
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    "Orders retrieved successfully", orders));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error retrieving orders: " + e.getMessage(), null));
        }
    }

    /**
     * Get list of supported payment methods
     */
    @GetMapping("/payment-methods")
    public ResponseEntity<ApiResponse<?>> getSupportedPaymentMethods() {
        try {
            List<String> paymentMethods = paymentService.getSupportedPaymentMethods();
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    "Payment methods retrieved successfully", paymentMethods));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error retrieving payment methods: " + e.getMessage(), null));
        }
    }

    /**
     * Get all orders - new endpoint for admin interface
     */
    @GetMapping
    public ResponseEntity<ApiResponse<?>> getAllOrders() {
        try {
            List<Order> orders = orderService.getAllOrders();
            return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "All orders retrieved successfully",
                    orders
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error retrieving orders: " + e.getMessage(), null));
        }
    }
}