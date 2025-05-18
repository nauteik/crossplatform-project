package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Address;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.OrderService;
import com.example.ecommerceproject.service.OrderStateManager;
import com.example.ecommerceproject.service.PaymentService;
import com.example.ecommerceproject.service.UserService;
import com.example.ecommerceproject.service.EmailService;
import com.example.ecommerceproject.service.CartService;
import com.example.ecommerceproject.service.ProductService;
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

    @Autowired
    private CartService cartService;

    @Autowired
    private ProductService productService;

    @PostMapping("/user/create")
    public ResponseEntity<ApiResponse<?>> createUserOrder(@RequestBody Map<String, Object> orderRequest) {
        try {
            String userId = (String) orderRequest.get("userId");
            String paymentMethod = (String) orderRequest.get("paymentMethod");
            List<String> selectedItemIds = (List<String>) orderRequest.get("selectedItemIds");
            String couponCode = (String) orderRequest.get("couponCode");
            
            // Lấy số điểm loyalty sử dụng (nếu có)
            Integer loyaltyPointsToUse = 0;
            if (orderRequest.containsKey("loyaltyPointsToUse")) {
                loyaltyPointsToUse = (Integer) orderRequest.get("loyaltyPointsToUse");
            }
            
            if (userId == null || paymentMethod == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Missing required fields: userId or paymentMethod", null));
            }
            
            // Xử lý địa chỉ giao hàng
            Address shippingAddress = (Address) orderRequest.get("shippingAddress");
            if (shippingAddress == null) {
                String addressId = (String) orderRequest.get("addressId");
                if (addressId != null) {
                    shippingAddress = userService.getAddressById(userId, addressId);
                }
                
                if (shippingAddress == null) {
                    return ResponseEntity.badRequest().body(
                        new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                            "Missing shipping address information", null));
                }
            }
            
            // Tạo đơn hàng với coupon và/hoặc loyalty points
            Order order;
            
            if (couponCode != null && !couponCode.isEmpty() && loyaltyPointsToUse > 0) {
                // Cả coupon và loyalty points
                order = orderService.createOrderWithCouponAndLoyaltyPoints(userId, shippingAddress, paymentMethod, 
                                                selectedItemIds, couponCode, loyaltyPointsToUse);
            } else if (couponCode != null && !couponCode.isEmpty()) {
                // Chỉ có coupon
                order = orderService.createOrderWithCoupon(userId, shippingAddress, paymentMethod, 
                                                selectedItemIds, couponCode);
            } else if (loyaltyPointsToUse > 0) {
                // Chỉ có loyalty points
                order = orderService.createOrderWithLoyaltyPoints(userId, shippingAddress, paymentMethod, 
                                                selectedItemIds, loyaltyPointsToUse);
            } else {
                // Không có giảm giá
                order = orderService.createOrder(userId, shippingAddress, paymentMethod, selectedItemIds);
            }
            
            return ResponseEntity.status(HttpStatus.CREATED).body(
                new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    "Order created successfully", order));
                    
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(
                new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "Error creating order: " + e.getMessage(), null));
        }
    }

    @PostMapping("/guest/create")
    public ResponseEntity<ApiResponse<?>> createGuestOrder(@RequestBody Map<String, Object> orderRequest) {
        try {
            // Xử lý thông tin khách hàng
            Map<String, Object> userInfo = (Map<String, Object>) orderRequest.get("userInfo");
            if (userInfo == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Missing user information for guest checkout", null));
            }
            
            String email = (String) userInfo.get("email");
            String username = (String) userInfo.get("username");
            String fullName = (String) userInfo.get("fullName");
            String phoneNumber = (String) userInfo.get("phoneNumber");
            
            // Kiểm tra email đã tồn tại chưa
            User existingUser = userService.findByEmail(email);
            if (existingUser != null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Email đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.", null));
            }
            
            // Kiểm tra username đã tồn tại chưa
            User existingUsername = userService.findByUsername(username);
            if (existingUsername != null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Tên đăng nhập đã được sử dụng. Vui lòng chọn tên đăng nhập khác.", null));
            }
            
            // Tạo mật khẩu ngẫu nhiên cho người dùng mới
            String password = generateRandomPassword();
            
            // Tạo người dùng mới với username
            User newUser = userService.createUser(email, username, password, fullName);
            String userId = newUser.getId();
            
            // Xử lý thông tin địa chỉ
            Map<String, Object> addressInfo = (Map<String, Object>) orderRequest.get("addressInfo");
            if (addressInfo == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Missing address information for guest checkout", null));
            }
            
            // Tạo địa chỉ mới
            Address newAddress = new Address();
            newAddress.setId(UUID.randomUUID().toString());
            newAddress.setFullName(fullName);
            newAddress.setPhoneNumber(phoneNumber);
            newAddress.setAddressLine((String) addressInfo.get("addressLine"));
            newAddress.setCity((String) addressInfo.get("city"));
            newAddress.setDistrict((String) addressInfo.get("district"));
            newAddress.setWard((String) addressInfo.get("ward"));
            newAddress.setDefault(true);
            
            // Lưu địa chỉ vào thông tin người dùng
            userService.addAddress(userId, newAddress);
            
            // Lấy phương thức thanh toán và mã coupon (nếu có)
            String paymentMethod = (String) orderRequest.get("paymentMethod");
            String couponCode = (String) orderRequest.get("couponCode");
            
            // Lấy danh sách sản phẩm
            List<String> selectedItemIds = (List<String>) orderRequest.get("selectedItemIds");
            
            // Tạo đơn hàng mới với userId đã tạo và áp dụng coupon nếu có
            Order order;
            if (couponCode != null && !couponCode.isEmpty()) {
                order = orderService.createOrderWithCoupon(userId, newAddress, paymentMethod, selectedItemIds, couponCode);
            } else {
                order = orderService.createOrder(userId, newAddress, paymentMethod, selectedItemIds);
            }
            
            // Tạo token cho người dùng mới
            String token = userService.generateAuthToken(userId);
            
            // Gửi email thông báo tài khoản mới
            Map<String, Object> emailData = new HashMap<>();
            emailData.put("to", email);
            emailData.put("subject", "Tài khoản mới đã được tạo");
            emailData.put("username", username);
            emailData.put("email", email);
            emailData.put("password", password);
            emailService.sendAccountCreationEmail(emailData);
            
            // Tạo response với thông tin tài khoản
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("order", order);
            responseData.put("userId", userId);
            responseData.put("username", username);
            responseData.put("password", password);
            responseData.put("message", "Tài khoản đã được tạo tự động. Vui lòng kiểm tra email để xem mật khẩu của bạn.");
            
            return ResponseEntity.status(HttpStatus.CREATED).body(
                new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    "Order created successfully with new account", responseData));
                    
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(
                new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "Error creating guest order: " + e.getMessage(), null));
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
                int pointsEarned = order.calculateLoyaltyPointsEarned();
                userService.addLoyaltyPoints(order.getUserId(), order.getFinalAmount());
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
    public ResponseEntity<ApiResponse<?>> getAllOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            // Log các tham số nhận được để debug
            System.out.println("Filter params - status: " + status + 
                               ", startDate: " + startDate + 
                               ", endDate: " + endDate +
                               ", page: " + page +
                               ", size: " + size);
            
            // Lấy và lọc danh sách đơn hàng
            Map<String, Object> result = orderService.getFilteredOrders(status, startDate, endDate, page, size);
            
            return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "Orders retrieved successfully",
                    result
            ));
        } catch (Exception e) {
            e.printStackTrace(); // In stack trace để dễ debug
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error retrieving orders: " + e.getMessage(), null));
        }
    }

    /**
     * Apply coupon to an existing order
     */
    @PostMapping("/{orderId}/apply-coupon")
    public ResponseEntity<ApiResponse<?>> applyCoupon(
            @PathVariable String orderId,
            @RequestBody Map<String, String> couponRequest) {
        try {
            String couponCode = couponRequest.get("couponCode");
            
            if (couponCode == null || couponCode.isEmpty()) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Missing coupon code", null));
            }
            
            Order updatedOrder = orderService.applyCouponToOrder(orderId, couponCode);
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Coupon applied successfully", updatedOrder));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(
                new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "Error applying coupon: " + e.getMessage(), null));
        }
    }

    /**
     * Lấy số điểm loyalty của người dùng
     */
    @GetMapping("/user/{userId}/loyalty-points")
    public ResponseEntity<ApiResponse<?>> getUserLoyaltyPoints(@PathVariable String userId) {
        try {
            int loyaltyPoints = userService.getLoyaltyPoints(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("userId", userId);
            response.put("loyaltyPoints", loyaltyPoints);
            response.put("equivalentAmount", loyaltyPoints * 1000); // 1 điểm = 1000 VND
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Loyalty points retrieved successfully",
                response
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "Error retrieving loyalty points: " + e.getMessage(), null));
        }
    }

    /**
     * Áp dụng điểm loyalty vào đơn hàng
     */
    @PostMapping("/{orderId}/apply-loyalty-points")
    public ResponseEntity<ApiResponse<?>> applyLoyaltyPoints(
            @PathVariable String orderId,
            @RequestBody Map<String, Integer> request) {
        try {
            if (!request.containsKey("points")) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Missing points parameter", null));
            }
            
            int pointsToUse = request.get("points");
            
            if (pointsToUse <= 0) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                        "Points must be greater than 0", null));
            }
            
            Order updatedOrder = orderService.applyLoyaltyPointsToOrder(orderId, pointsToUse);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                String.format("Successfully applied %d loyalty points to order", pointsToUse),
                updatedOrder
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(
                new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "Error applying loyalty points: " + e.getMessage(), null));
        }
    }
}