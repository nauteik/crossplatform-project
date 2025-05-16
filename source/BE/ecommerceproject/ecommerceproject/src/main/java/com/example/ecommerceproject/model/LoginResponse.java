package com.example.ecommerceproject.model;

import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@Getter
@Setter
public class LoginResponse {
    private String token;
    private String id;
    private String username;
    private int role;
    private String email;
    private String name;

    public LoginResponse(String token, String id, String username, int role) {
        this.token = token;
        this.username = username;
        this.id = id;
        this.role = role;
    }
}