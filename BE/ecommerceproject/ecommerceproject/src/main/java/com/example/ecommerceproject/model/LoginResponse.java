package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class LoginResponse {
    private String token;
    private String username;
    private String email;
    private int role;

    public LoginResponse(String token, String username, String email, int role) {
        this.token = token;
        this.username = username;
        this.email = email;
        this.role = role;
    }
    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public int getRole() {
        return role;
    }
}