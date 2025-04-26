package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.OrderService;
import com.example.ecommerceproject.service.PaymentService; // Still needed for getSupportedPaymentMethods
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin("*")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<?>> createOrder(
            @RequestBody Map<String, Object> orderRequest) {
        try {
            String userId = (String) orderRequest.get("userId");
            String shippingAddress = (String) orderRequest.get("shippingAddress");
            String paymentMethod = (String) orderRequest.get("paymentMethod");

            List<String> selectedItemIds = null;
            Object selectedItemIdsObj = orderRequest.get("selectedItemIds");
            if (selectedItemIdsObj != null) {
                if (selectedItemIdsObj instanceof List) {
                    try {
                        selectedItemIds = ((List<?>) selectedItemIdsObj).stream()
                                .map(String.class::cast)
                                .collect(Collectors.toList());
                    } catch (ClassCastException e) {
                        return ResponseEntity.badRequest().body(
                                new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                        "Invalid format for selectedItemIds. Expected list of strings.", null));
                    }
                } else {
                    return ResponseEntity.badRequest().body(
                            new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                    "Invalid format for selectedItemIds. Expected a list.", null));
                }
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

    @PutMapping("/{orderId}/status")
    public ResponseEntity<ApiResponse<?>> updateOrderStatus(
            @PathVariable String orderId,
            @RequestBody Map<String, String> statusRequest) {
        try {
            String statusStr = statusRequest.get("status");
            if (statusStr == null) {
                return ResponseEntity.badRequest().body(
                        new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                "Status is required", null));
            }

            OrderStatus newStatus;
            try {
                newStatus = OrderStatus.valueOf(statusStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body(
                        new ApiResponse<>(ApiStatus.BAD_REQUEST.getCode(),
                                "Invalid status value", null));
            }

            Order updatedOrder = orderService.updateOrderStatus(orderId, newStatus);
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(),
                    "Order status updated successfully", updatedOrder));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Error updating order status: " + e.getMessage(), null));
        }
    }

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
}