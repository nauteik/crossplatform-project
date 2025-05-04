package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.OrderService;
import com.example.ecommerceproject.service.OrderStateManager;
import com.example.ecommerceproject.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
    
    /**
     * Create a new order with PENDING status
     */
    @PostMapping("/create")
    public ResponseEntity<ApiResponse<?>> createOrder(
            @RequestBody Map<String, Object> orderRequest) {
        try {
            String userId = (String) orderRequest.get("userId");
            String shippingAddress = (String) orderRequest.get("shippingAddress");
            String paymentMethod = (String) orderRequest.get("paymentMethod");
            
            // Get selectedItemIds from the request - handle potential null or type conversion
            List<String> selectedItemIds = null;
            Object selectedItemIdsObj = orderRequest.get("selectedItemIds");
            if (selectedItemIdsObj instanceof List) {
                selectedItemIds = (List<String>) selectedItemIdsObj;
            }
            
            if (userId == null || shippingAddress == null || paymentMethod == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(), 
                    "Missing required fields: userId, shippingAddress, or paymentMethod", null));
            }
            
            Order order = orderService.createOrder(userId, shippingAddress, paymentMethod, selectedItemIds);
            
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