package com.example.ecommerceproject.model;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class CartItemRequest {
    private String productId;
    private String productName;
    private int quantity;
    private double price;
    private String imageUrl;
}