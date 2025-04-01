package com.example.ecommerceproject.controller;

import java.util.List;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.UserRepository;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.security.JwtUtil;
import com.example.ecommerceproject.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping(path = "/user")
@CrossOrigin("*") // Cho phép frontend gọi API
public class UserController {

    @Autowired
    private UserRepository userRepo;
    
    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/add")
    public User addUser(@RequestBody User user) {
        return userRepo.save(user);
    }

    @GetMapping("/getAll")
    public List<User> getAllUser(){
        return userRepo.findAll();
    }
    
    /**
     * Cập nhật thông tin người dùng
     * @param userId ID của người dùng cần cập nhật
     * @param updatedUser Thông tin người dùng mới
     * @return ResponseEntity với ApiResponse chứa UserDTO đã cập nhật
     */
    @PutMapping("/edit/{userId}")
    public ResponseEntity<ApiResponse<?>> updateUser(
            @PathVariable String userId,
            @RequestBody User updatedUser) {
        try {
            User updated = userService.updateUser(userId, updatedUser);
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "User updated successfully",
                updated
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("User not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ApiResponse<>(
                            ApiStatus.NOT_FOUND.getCode(),
                            e.getMessage(),
                            null
                        ));
            } else if (e.getMessage().contains("Email already in use")) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ApiResponse<>(
                            ApiStatus.EMAIL_ALREADY_EXISTS.getCode(),
                            ApiStatus.EMAIL_ALREADY_EXISTS.getMessage(),
                            null
                        ));
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(new ApiResponse<>(
                            ApiStatus.SERVER_ERROR.getCode(),
                            "Update failed: " + e.getMessage(),
                            null
                        ));
            }
        }
    }

    /**
     * Lấy thông tin người dùng theo ID
     * @param userId ID của người dùng
     * @return ResponseEntity với ApiResponse chứa thông tin người dùng
     */
    @GetMapping("/get/{userId}")
    public ResponseEntity<ApiResponse<?>> getUserById(@PathVariable String userId) {
        try {
            User user = userService.getUserById(userId);
            
            // Bảo mật: Không trả về mật khẩu đã mã hóa cho client
            user.setPassword(null);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "User retrieved successfully",
                user
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    e.getMessage(),
                    null
                ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Failed to retrieve user: " + e.getMessage(),
                    null
                ));
        }
    }

    /**
     * Lấy thông tin người dùng hiện tại từ token JWT
     * @param request HttpServletRequest chứa token JWT
     * @return ResponseEntity với ApiResponse chứa thông tin người dùng
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<?>> getCurrentUser(HttpServletRequest request) {
        try {
            String authHeader = request.getHeader("Authorization");
            
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                String username = jwtUtil.extractUsername(token);
                User user = userService.getUserByUsername(username);
                
                // Bảo mật: Không trả về mật khẩu đã mã hóa cho client
                user.setPassword(null);
                
                return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "Current user retrieved successfully",
                    user
                ));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(
                        401,
                        "Authorization token not found or invalid",
                        null
                    ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Failed to retrieve current user: " + e.getMessage(),
                    null
                ));
        }
    }
}

