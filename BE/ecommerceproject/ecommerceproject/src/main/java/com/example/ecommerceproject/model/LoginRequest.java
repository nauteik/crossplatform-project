package com.example.ecommerceproject.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class LoginRequest {
    private String username;
    private String password;
    private String token; //xử lý đăng nhập Google
}
