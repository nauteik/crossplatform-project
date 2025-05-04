package com.example.ecommerceproject.auth;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.response.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

import java.util.List;
@Component
public class AuthenticationServiceManager {
    
    private final List<AuthenticationService> authServices;
    
    @Autowired
    public AuthenticationServiceManager(List<AuthenticationService> authServices) {
        this.authServices = authServices;
    }
    
    public ResponseEntity<ApiResponse<?>> authenticate(AuthenticationRequest request) {
        for (AuthenticationService service : authServices) {
            if (service.supports(request.getType())) {
                return service.authenticate(request);
            }
        }
        
        return ResponseEntity.badRequest().body(
            new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                "Unsupported authentication type: " + request.getType(), null)
        );
    }
}