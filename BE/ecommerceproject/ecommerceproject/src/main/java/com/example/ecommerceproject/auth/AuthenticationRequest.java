package com.example.ecommerceproject.auth;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthenticationRequest {
    private AuthenticationType type;
    private String username; // Used for local authentication
    private String password; // Used for local authentication
    private String token;    // Used for Google authentication
}