package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
@Getter
@Setter
public class User {

    @Id
    private String id;

    private String email;
    private String password;

    private String avatar;
    private String name;
    private String username;
    private String phone;
    private String gender;
    private Date birthday;
    private LocalDateTime createdAt = LocalDateTime.now();

    private String rank;
    private int totalSpend;
    private int loyaltyPoints = 0;

    private int role;
    
}
