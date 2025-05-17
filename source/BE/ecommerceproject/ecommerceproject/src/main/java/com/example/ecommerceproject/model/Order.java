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
    private String couponCode;
    private double couponDiscount;
    private int loyaltyPointsUsed;  // Số điểm loyalty đã sử dụng
    private double loyaltyPointsDiscount; // Số tiền giảm giá từ điểm loyalty
    private OrderStatus status;
    private String paymentMethod;  // e.g., "CREDIT_CARD", "COD"
    private Address shippingAddress;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Lịch sử trạng thái đơn hàng
    private List<StatusHistoryEntry> statusHistory = new ArrayList<>();
    
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
        this.loyaltyPointsUsed = 0;
        this.loyaltyPointsDiscount = 0;
        
        // Thêm trạng thái ban đầu vào lịch sử
        this.statusHistory.add(new StatusHistoryEntry(status, this.createdAt, "Đơn hàng được tạo"));
    }
    
    // Method to update the order status
    public void updateStatus(OrderStatus newStatus) {
        // Lưu trạng thái cũ
        OrderStatus oldStatus = this.status;
        
        // Cập nhật trạng thái mới
        this.status = newStatus;
        this.updatedAt = LocalDateTime.now();
        
        // Thêm vào lịch sử trạng thái
        String message = generateStatusChangeMessage(oldStatus, newStatus);
        this.statusHistory.add(new StatusHistoryEntry(newStatus, this.updatedAt, message));
    }
    
    // Phương thức tạo message cho việc thay đổi trạng thái
    private String generateStatusChangeMessage(OrderStatus oldStatus, OrderStatus newStatus) {
        switch (newStatus) {
            case PAID:
                return "Đơn hàng đã được thanh toán";
            case SHIPPING:
                return "Đơn hàng đang được vận chuyển";
            case DELIVERED:
                return "Đơn hàng đã được giao thành công";
            case CANCELLED:
                return "Đơn hàng đã bị hủy";
            case FAILED:
                return "Thanh toán đơn hàng thất bại";
            default:
                return "Trạng thái đơn hàng đã thay đổi từ " + oldStatus + " sang " + newStatus;
        }
    }
    
    // Phương thức để thiết lập thông tin bổ sung
    public void setAdditionalInfo(Map<String, Object> additionalInfo) {
        this.additionalInfo = additionalInfo;
    }
    
    // Phương thức để lấy thông tin bổ sung
    public Map<String, Object> getAdditionalInfo() {
        return this.additionalInfo;
    }
    
    // Phương thức áp dụng coupon
    public void applyCoupon(String couponCode, double discount) {
        this.couponCode = couponCode;
        this.couponDiscount = discount;
        this.updatedAt = LocalDateTime.now();
    }
    
    // Phương thức áp dụng điểm loyalty
    public void applyLoyaltyPoints(int points, double discount) {
        this.loyaltyPointsUsed = points;
        this.loyaltyPointsDiscount = discount;
        this.updatedAt = LocalDateTime.now();
    }
    
    // Phương thức lấy tổng tiền sau khi áp dụng coupon và điểm loyalty
    public double getFinalAmount() {
        return this.totalAmount - this.couponDiscount - this.loyaltyPointsDiscount;
    }
    
    // Phương thức tính số điểm loyalty sẽ nhận được (10% của tổng tiền cuối cùng / 1000)
    // 1 điểm tương đương 1000 VND
    public int calculateLoyaltyPointsEarned() {
        double finalAmount = getFinalAmount();
        return (int)(finalAmount * 0.1 / 1000);
    }
}