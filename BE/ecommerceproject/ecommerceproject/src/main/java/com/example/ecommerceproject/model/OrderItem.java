package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderItem {
    private String productId;
    private String productName;
    private int quantity;
    private double price;  // Price per item at the time of order
    private String imageUrl;
}