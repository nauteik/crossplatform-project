package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Address {
    private String id;
    private String fullName;
    private String phoneNumber;
    private String addressLine;
    private String city;
    private String district;
    private String ward;
    private boolean isDefault;
} 