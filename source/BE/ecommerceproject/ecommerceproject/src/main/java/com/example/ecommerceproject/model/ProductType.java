package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "product_types")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductType {
    @Id
    private String id;
    
    private String name;
} 