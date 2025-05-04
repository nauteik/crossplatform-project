package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.auth.AuthenticationRequest;
import com.example.ecommerceproject.auth.AuthenticationServiceManager;
import com.example.ecommerceproject.auth.AuthenticationType;
import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.LoginRequest;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.security.JwtUtil;
import com.example.ecommerceproject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin("*")
public class AuthController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private AuthenticationServiceManager authManager;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private JwtUtil jwtUtil; // Inject JwtUtil
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<?>> registerUser(@RequestBody User user) {
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
            User newUser = userService.registerUser(user);
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
    
    // Đảm bảo phương thức localLogin trong AuthController đã tạo token với thông tin role
    @PostMapping("/login/local")
    public ResponseEntity<ApiResponse<?>> localLogin(@RequestBody LoginRequest loginRequest) {
        try {
            // Validate request params
            if (loginRequest.getUsername() == null || loginRequest.getPassword() == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(),
                                "Tên đăng nhập và mật khẩu không được để trống", null));
            }
            
            // Tìm user theo username
            User user = userService.getUserByUsername(loginRequest.getUsername());
            if (user == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(),
                                "Thông tin đăng nhập không hợp lệ", null));
            }
            
            // Kiểm tra mật khẩu
            if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(),
                                "Thông tin đăng nhập không hợp lệ", null));
            }
            
            // Tạo JWT token với role
            String token = jwtUtil.generateTokenWithRole(user.getUsername(), user.getRole());
            
            // Chuẩn bị dữ liệu phản hồi
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("token", token);
            
            // Ẩn mật khẩu trước khi trả về user
            user.setPassword(null);
            responseData.put("user", user);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Đăng nhập thành công",
                responseData));
                
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                            "Lỗi đăng nhập: " + e.getMessage(), null));
        }
    }
    
    @PostMapping("/login/google")
    public ResponseEntity<ApiResponse<?>> googleLogin(@RequestBody Map<String, String> requestBody) {
        String googleToken = requestBody.get("token");
        
        if (googleToken == null || googleToken.isEmpty()) {
            return ResponseEntity.badRequest().body(
                new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(),
                               "Google token is required", null));
        }
        
        // Sử dụng AuthenticationServiceManager với AuthenticationType.OAUTH2
        AuthenticationRequest request = new AuthenticationRequest();
        request.setType(AuthenticationType.OAUTH2);
        request.setToken(googleToken);
        
        return authManager.authenticate(request);
    }
    // Endpoint cho OAuth2 success redirect
    @GetMapping("/oauth2-success")
    public ResponseEntity<ApiResponse<?>> oauth2LoginSuccess(@AuthenticationPrincipal OAuth2User principal) {
        // Xử lý khi đăng nhập OAuth2 thành công
        // Có thể redirect về trang frontend với token JWT
        return ResponseEntity.ok(new ApiResponse<>(
            ApiStatus.SUCCESS.getCode(), 
            "OAuth2 login successful", 
            principal.getAttributes()
        ));
    }
}
