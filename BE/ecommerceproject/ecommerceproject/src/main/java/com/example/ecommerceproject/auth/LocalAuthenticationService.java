package com.example.ecommerceproject.auth;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.LoginRequest;
import com.example.ecommerceproject.model.LoginResponse;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.security.JwtUtil;
import com.example.ecommerceproject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
public class LocalAuthenticationService implements AuthenticationService {

    @Autowired
    private UserService userService;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Override
    public ResponseEntity<ApiResponse<?>> authenticate(AuthenticationRequest request) {
        try {
            // Validate request
            if (request.getUsername() == null || request.getPassword() == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(), 
                                     "Username and password are required", null));
            }
            
            // Authenticate user with local credentials
            User authenticatedUser = userService.authenticateUser(
                request.getUsername(), request.getPassword());
            
            // Generate JWT token
            UserDetails userDetails = userService.loadUserByUsername(request.getUsername());
            String token = jwtUtil.generateToken(userDetails);
            
            // Create response
            LoginResponse loginResponse = new LoginResponse(
                token,
                authenticatedUser.getId(),
                authenticatedUser.getUsername(),
                authenticatedUser.getRole()
            );
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Local authentication successful",
                loginResponse
            ));
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ApiResponse<>(401, "Invalid username or password", null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "Authentication failed: " + e.getMessage(), null));
        }
    }

    @Override
    public boolean supports(AuthenticationType type) {
        return AuthenticationType.LOCAL.equals(type);
    }
}