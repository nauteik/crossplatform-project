package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.List;

@Document(collection = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    @Id
    private String id;
    
    private String name;
    private double price;
    private int quantity;
    private String description;
    private String primaryImageUrl; // Ảnh chính
    private List<String> imageUrls; // Danh sách các ảnh khác
    private int soldCount;
    private double discountPercent;
    
    @DBRef
    private Brand brand;
    
    @DBRef
    private ProductType productType;
} 