package com.example.ecommerceproject.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private String id;
    private String name;
    private double price;
    private int quantity;
    private String description;
    private String imageUrl;
    private int soldCount;
    private double discountPercent;
    private String brandId;
    private String brandName;
    private String productTypeId;
    private String productTypeName;
} 