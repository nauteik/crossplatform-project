package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.auth.AuthenticationRequest;
import com.example.ecommerceproject.auth.AuthenticationServiceManager;
import com.example.ecommerceproject.auth.AuthenticationType;
import com.example.ecommerceproject.auth.GoogleAuthClient;
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
    private GoogleAuthClient googleAuthClient;

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
    
    @PostMapping("/login/local")
    public ResponseEntity<ApiResponse<?>> localLogin(@RequestBody LoginRequest loginRequest) {
        AuthenticationRequest request = new AuthenticationRequest();
        request.setType(AuthenticationType.LOCAL);
        request.setUsername(loginRequest.getUsername());
        request.setPassword(loginRequest.getPassword());
        
        return authManager.authenticate(request);
    }
    
@PostMapping("/login/google")
public ResponseEntity<ApiResponse<?>> googleLogin(@RequestBody Map<String, String> requestBody) {
    String googleToken = requestBody.get("token");

    if (googleToken == null || googleToken.isEmpty()) {
        return ResponseEntity.badRequest().body(
            new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(),
                             "Google token is required", null));
    }

    // Xác thực token Google và lấy thông tin người dùng
    GoogleAuthClient.GoogleUserInfo userInfo = googleAuthClient.verifyGoogleToken(googleToken);

    // Tạo đối tượng UserDetails từ thông tin người dùng
    UserDetails userDetails = new org.springframework.security.core.userdetails.User(
        userInfo.getEmail(),
        "", // Password không cần thiết cho OAuth2
        Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")) // Gán quyền mặc định
    );

    // Tạo JWT token
    String jwtToken = jwtUtil.generateToken(userDetails);

    // Trả về phản hồi
    Map<String, Object> responseData = new HashMap<>();
    responseData.put("token", jwtToken);
    responseData.put("user", userInfo);

    return ResponseEntity.ok(new ApiResponse<>(
        ApiStatus.SUCCESS.getCode(),
        "Google authentication successful",
        responseData
    ));
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
