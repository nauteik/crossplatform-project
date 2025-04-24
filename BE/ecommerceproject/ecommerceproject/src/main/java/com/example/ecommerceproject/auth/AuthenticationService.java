package com.example.ecommerceproject.auth;

import com.example.ecommerceproject.response.ApiResponse;
import org.springframework.http.ResponseEntity;

/**
 * Target interface for the Adapter Pattern
 * Defines the common authentication operations
 */
public interface AuthenticationService {
    ResponseEntity<ApiResponse<?>> authenticate(AuthenticationRequest request);
    boolean supports(AuthenticationType type);
}