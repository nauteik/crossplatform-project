package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Address;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.security.JwtUtil;
import com.example.ecommerceproject.service.AddressService;
import com.example.ecommerceproject.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/address")
@CrossOrigin("*")
public class AddressController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private AddressService addressService;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Lấy danh sách địa chỉ của người dùng
     * @param userId ID của người dùng
     * @param request HttpServletRequest chứa token JWT
     * @return ResponseEntity với ApiResponse chứa danh sách địa chỉ
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<?>> getUserAddresses(
            @PathVariable String userId,
            HttpServletRequest request) {
        try {
            // Xác thực người dùng từ token JWT
            String authHeader = request.getHeader("Authorization");
            
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ApiResponse<>(
                            401,
                            "Yêu cầu xác thực token",
                            null
                        ));
            }
            
            String token = authHeader.substring(7);
            String username = jwtUtil.extractUsername(token);
            
            // Kiểm tra người dùng hiện tại
            User currentUser = userService.getUserByUsername(username);
            
            // Chỉ admin hoặc chính người dùng đó mới có thể xem địa chỉ
            if (currentUser.getRole() != 1 && !currentUser.getId().equals(userId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ApiResponse<>(
                            403,
                            "Bạn không có quyền xem địa chỉ của người dùng này",
                            null
                        ));
            }
            
            List<Address> addresses = addressService.getUserAddresses(userId);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Lấy danh sách địa chỉ thành công",
                addresses
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(
                        ApiStatus.SERVER_ERROR.getCode(),
                        "Lỗi khi lấy danh sách địa chỉ: " + e.getMessage(),
                        null
                    ));
        }
    }

    /**
     * Thêm địa chỉ mới cho người dùng
     * @param userId ID của người dùng
     * @param address Địa chỉ mới
     * @param request HttpServletRequest chứa token JWT
     * @return ResponseEntity với ApiResponse chứa người dùng đã cập nhật
     */
    @PostMapping("/{userId}")
    public ResponseEntity<ApiResponse<?>> addAddress(
            @PathVariable String userId,
            @RequestBody Address address,
            HttpServletRequest request) {
        try {
            // Xác thực người dùng từ token JWT
            String authHeader = request.getHeader("Authorization");
            
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ApiResponse<>(
                            401,
                            "Yêu cầu xác thực token",
                            null
                        ));
            }
            
            String token = authHeader.substring(7);
            String username = jwtUtil.extractUsername(token);
            
            // Kiểm tra người dùng hiện tại
            User currentUser = userService.getUserByUsername(username);
            
            // Chỉ admin hoặc chính người dùng đó mới có thể thêm địa chỉ
            if (currentUser.getRole() != 1 && !currentUser.getId().equals(userId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ApiResponse<>(
                            403,
                            "Bạn không có quyền thêm địa chỉ cho người dùng này",
                            null
                        ));
            }
            
            Address newAddress = addressService.addAddress(userId, address);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Thêm địa chỉ thành công",
                newAddress
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>(
                        ApiStatus.BAD_REQUEST.getCode(),
                        e.getMessage(),
                        null
                    ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(
                        ApiStatus.SERVER_ERROR.getCode(),
                        "Lỗi khi thêm địa chỉ: " + e.getMessage(),
                        null
                    ));
        }
    }

    /**
     * Cập nhật địa chỉ của người dùng
     * @param userId ID của người dùng
     * @param addressId ID của địa chỉ
     * @param address Địa chỉ đã cập nhật
     * @param request HttpServletRequest chứa token JWT
     * @return ResponseEntity với ApiResponse chứa người dùng đã cập nhật
     */
    @PutMapping("/{userId}/{addressId}")
    public ResponseEntity<ApiResponse<?>> updateAddress(
            @PathVariable String userId,
            @PathVariable String addressId,
            @RequestBody Address address,
            HttpServletRequest request) {
        try {
            // Xác thực người dùng từ token JWT
            String authHeader = request.getHeader("Authorization");
            
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ApiResponse<>(
                            401,
                            "Yêu cầu xác thực token",
                            null
                        ));
            }
            
            String token = authHeader.substring(7);
            String username = jwtUtil.extractUsername(token);
            
            // Kiểm tra người dùng hiện tại
            User currentUser = userService.getUserByUsername(username);
            
            // Chỉ admin hoặc chính người dùng đó mới có thể cập nhật địa chỉ
            if (currentUser.getRole() != 1 && !currentUser.getId().equals(userId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ApiResponse<>(
                            403,
                            "Bạn không có quyền cập nhật địa chỉ của người dùng này",
                            null
                        ));
            }
            
            Address updatedAddress = addressService.updateAddress(userId, addressId, address);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Cập nhật địa chỉ thành công",
                updatedAddress
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>(
                        ApiStatus.BAD_REQUEST.getCode(),
                        e.getMessage(),
                        null
                    ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(
                        ApiStatus.SERVER_ERROR.getCode(),
                        "Lỗi khi cập nhật địa chỉ: " + e.getMessage(),
                        null
                    ));
        }
    }

    /**
     * Xóa địa chỉ của người dùng
     * @param userId ID của người dùng
     * @param addressId ID của địa chỉ
     * @param request HttpServletRequest chứa token JWT
     * @return ResponseEntity với ApiResponse chứa người dùng đã cập nhật
     */
    @DeleteMapping("/{userId}/{addressId}")
    public ResponseEntity<ApiResponse<?>> deleteAddress(
            @PathVariable String userId,
            @PathVariable String addressId,
            HttpServletRequest request) {
        try {
            // Xác thực người dùng từ token JWT
            String authHeader = request.getHeader("Authorization");
            
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ApiResponse<>(
                            401,
                            "Yêu cầu xác thực token",
                            null
                        ));
            }
            
            String token = authHeader.substring(7);
            String username = jwtUtil.extractUsername(token);
            
            // Kiểm tra người dùng hiện tại
            User currentUser = userService.getUserByUsername(username);
            
            // Chỉ admin hoặc chính người dùng đó mới có thể xóa địa chỉ
            if (currentUser.getRole() != 1 && !currentUser.getId().equals(userId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ApiResponse<>(
                            403,
                            "Bạn không có quyền xóa địa chỉ của người dùng này",
                            null
                        ));
            }
            
            addressService.deleteAddress(userId, addressId);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Xóa địa chỉ thành công",
                null
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>(
                        ApiStatus.BAD_REQUEST.getCode(),
                        e.getMessage(),
                        null
                    ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(
                        ApiStatus.SERVER_ERROR.getCode(),
                        "Lỗi khi xóa địa chỉ: " + e.getMessage(),
                        null
                    ));
        }
    }

    /**
     * Đặt địa chỉ mặc định cho người dùng
     * @param userId ID của người dùng
     * @param addressId ID của địa chỉ
     * @param request HttpServletRequest chứa token JWT
     * @return ResponseEntity với ApiResponse chứa người dùng đã cập nhật
     */
    @PutMapping("/{userId}/{addressId}/default")
    public ResponseEntity<ApiResponse<?>> setDefaultAddress(
            @PathVariable String userId,
            @PathVariable String addressId,
            HttpServletRequest request) {
        try {
            // Xác thực người dùng từ token JWT
            String authHeader = request.getHeader("Authorization");
            
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ApiResponse<>(
                            401,
                            "Yêu cầu xác thực token",
                            null
                        ));
            }
            
            String token = authHeader.substring(7);
            String username = jwtUtil.extractUsername(token);
            
            // Kiểm tra người dùng hiện tại
            User currentUser = userService.getUserByUsername(username);
            
            // Chỉ admin hoặc chính người dùng đó mới có thể đặt địa chỉ mặc định
            if (currentUser.getRole() != 1 && !currentUser.getId().equals(userId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ApiResponse<>(
                            403,
                            "Bạn không có quyền đặt địa chỉ mặc định cho người dùng này",
                            null
                        ));
            }
            
            Address defaultAddress = addressService.setDefaultAddress(userId, addressId);
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Đặt địa chỉ mặc định thành công",
                defaultAddress
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>(
                        ApiStatus.BAD_REQUEST.getCode(),
                        e.getMessage(),
                        null
                    ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(
                        ApiStatus.SERVER_ERROR.getCode(),
                        "Lỗi khi đặt địa chỉ mặc định: " + e.getMessage(),
                        null
                    ));
        }
    }
} 