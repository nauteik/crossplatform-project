package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Coupon;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/coupons")
@CrossOrigin("*")
public class CouponController {

    @Autowired
    private CouponService couponService;

    // API lấy tất cả coupon
    @GetMapping
    public ResponseEntity<ApiResponse<?>> getAllCoupons() {
        try {
            List<Coupon> coupons = couponService.getAllCoupons();
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Lấy danh sách coupon thành công",
                coupons
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Lỗi khi lấy danh sách coupon: " + e.getMessage(),
                    null
                )
            );
        }
    }

    // API tạo coupon mới
    @PostMapping
    public ResponseEntity<ApiResponse<?>> createCoupon(@RequestBody Coupon coupon) {
        try {
            Coupon createdCoupon = couponService.updateCoupon(coupon);
            return ResponseEntity.status(HttpStatus.CREATED).body(
                new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "Tạo coupon thành công",
                    createdCoupon
                )
            );
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Lỗi khi tạo coupon: " + e.getMessage(),
                    null
                )
            );
        }
    }

    // API kiểm tra coupon
    @GetMapping("/check/{code}")
    public ResponseEntity<ApiResponse<?>> checkCouponCode(@PathVariable String code) {
        try {
            Map<String, Object> couponDetails = couponService.getCouponDetails(code);
            
            if ((Boolean) couponDetails.get("valid")) {
                return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "Coupon hợp lệ",
                    couponDetails
                ));
            } else {
                return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    couponDetails.containsKey("message") ? 
                        (String) couponDetails.get("message") : "Coupon không hợp lệ",
                    couponDetails
                ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Lỗi khi kiểm tra coupon: " + e.getMessage(),
                    null
                )
            );
        }
    }

    // API cập nhật coupon
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> updateCoupon(@PathVariable String id, @RequestBody Coupon coupon) {
        try {
            coupon.setId(id);
            Coupon updatedCoupon = couponService.updateCoupon(coupon);
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Cập nhật coupon thành công",
                updatedCoupon
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Lỗi khi cập nhật coupon: " + e.getMessage(),
                    null
                )
            );
        }
    }

    // API xóa coupon
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> deleteCoupon(@PathVariable String id) {
        try {
            couponService.deleteCoupon(id);
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Xóa coupon thành công",
                null
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Lỗi khi xóa coupon: " + e.getMessage(),
                    null
                )
            );
        }
    }
}