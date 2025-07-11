package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "addresses")
public class Address {
    @Id
    private String id;
    
    private String userId;
    private String fullName;
    private String phoneNumber;
    private String addressLine;
    private String city;
    private String district;
    private String ward;
    private boolean isDefault;
} 