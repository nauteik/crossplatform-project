package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "orders")
public class Order {
    @Id
    private String id;
    private String userId;
    private List<OrderItem> items = new ArrayList<>();
    private double totalAmount;
    private OrderStatus status;
    private String paymentMethod;  // e.g., "CREDIT_CARD", "COD"
    private Address shippingAddress;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // AdditionalInfo để lưu trữ thông tin Username, Email
    // @Transient đảm bảo trường này không được lưu vào database
    @Transient
    private Map<String, Object> additionalInfo = new HashMap<>();
    
    // Constructor that initializes dates
    public Order(String userId, List<OrderItem> items, double totalAmount, 
                OrderStatus status, String paymentMethod, Address shippingAddress) {
        this.userId = userId;
        this.items = items;
        this.totalAmount = totalAmount;
        this.status = status;
        this.paymentMethod = paymentMethod;
        this.shippingAddress = shippingAddress;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.additionalInfo = new HashMap<>();
    }
    
    // Method to update the order status
    public void updateStatus(OrderStatus newStatus) {
        this.status = newStatus;
        this.updatedAt = LocalDateTime.now();
    }
    
    // Phương thức để thiết lập thông tin bổ sung
    public void setAdditionalInfo(Map<String, Object> additionalInfo) {
        this.additionalInfo = additionalInfo;
    }
    
    // Phương thức để lấy thông tin bổ sung
    public Map<String, Object> getAdditionalInfo() {
        return this.additionalInfo;
    }
}