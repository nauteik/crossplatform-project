package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Getter
public class LoginResponse {
    private String token;
    private String id;
    private String username;
    private int role;

    public LoginResponse(String token, String id, String username, int role) {
        this.token = token;
        this.username = username;
        this.id = id;
        this.role = role;
    }
}