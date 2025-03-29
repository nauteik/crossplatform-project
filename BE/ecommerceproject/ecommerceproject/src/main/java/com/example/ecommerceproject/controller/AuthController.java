package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.LoginRequest;
import com.example.ecommerceproject.model.LoginResponse;
import com.example.ecommerceproject.model.UserDTO;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.security.JwtUtil;
import com.example.ecommerceproject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin("*") // Cho phép frontend gọi API
public class AuthController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<?>> registerUser(@RequestBody UserDTO user) {
        try {
            // Kiểm tra username đã tồn tại chưa
            if (userService.isUsernameExists(user.getUsername())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ApiResponse<>(
                            ApiStatus.USER_ALREADY_EXISTS.getCode(),
                            ApiStatus.USER_ALREADY_EXISTS.getMessage(),
                            null));
            }
            
            // Nếu username chưa tồn tại, tiến hành đăng ký
            UserDTO newUser = userService.registerUser(user);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new ApiResponse<>(
                        ApiStatus.SUCCESS.getCode(),
                        "User registered successfully!",
                        newUser));
                        
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(
                        ApiStatus.SERVER_ERROR.getCode(),
                        "Registration failed: " + e.getMessage(),
                        null));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<?>> login(@RequestBody LoginRequest loginRequest) {
        try {
            // Xác thực người dùng
            UserDTO authenticatedUser = userService.authenticateUser(loginRequest.getUsername(), loginRequest.getPassword());
            
            // Tạo JWT token
            UserDetails userDetails = userService.loadUserByUsername(loginRequest.getUsername());
            String token = jwtUtil.generateToken(userDetails);
            
            // Tạo response
            LoginResponse loginResponse = new LoginResponse(
                    token,
                    authenticatedUser.getId(),
                    authenticatedUser.getUsername(),
                    authenticatedUser.getRole()
            );
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Login successful",
                loginResponse
            ));
            
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ApiResponse<>(
                    401,
                    "Invalid username or password",
                    null
                ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Login failed: " + e.getMessage(),
                    null
                ));
        }
    }
}
