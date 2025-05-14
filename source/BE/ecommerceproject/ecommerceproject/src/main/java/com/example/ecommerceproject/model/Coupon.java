package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "coupons")
public class Coupon {

    @Id
    private String id;

    private String code;

    private int value;

    private int maxUses;

    private int usedCount;

    private LocalDateTime creationTime;

    private List<String> ordersApplied = new ArrayList<>();

    // Constructor với các tham số cơ bản
    public Coupon(String code, int value, int maxUses) {
        this.code = code;
        this.value = value;
        this.maxUses = maxUses;
        this.usedCount = 0;
        this.creationTime = LocalDateTime.now();
    }

    // Phương thức kiểm tra xem coupon có thể sử dụng được không
    public boolean isValid() {
        return usedCount < maxUses;
    }

    // Phương thức áp dụng coupon vào đơn hàng
    public boolean applyToOrder(String orderId) {
        if (isValid() && !ordersApplied.contains(orderId)) {
            ordersApplied.add(orderId);
            usedCount++;
            return true;
        }
        return false;
    }
}