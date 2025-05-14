package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.model.Coupon;
import com.example.ecommerceproject.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/coupon")
public class CouponController {

    private final CouponService couponService;

    @Autowired
    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @PostMapping
    public ResponseEntity<Coupon> createCoupon(@RequestBody Coupon coupon) {
        Coupon createdCoupon = couponService.createCoupon(coupon);
        return new ResponseEntity<>(createdCoupon, HttpStatus.CREATED);
    }

    @GetMapping("/coupons")
    public ResponseEntity<List<Coupon>> getAllCoupons() {
        List<Coupon> coupons = couponService.getAllCoupons();
        return new ResponseEntity<>(coupons, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Coupon> getCouponById(@PathVariable String id) {
        return couponService.getCouponById(id)
                .map(coupon -> new ResponseEntity<>(coupon, HttpStatus.OK))
                .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @GetMapping("/code/{code}")
    public ResponseEntity<Coupon> getCouponByCode(@PathVariable String code) {
        return couponService.getCouponByCode(code)
                .map(coupon -> new ResponseEntity<>(coupon, HttpStatus.OK))
                .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping("/apply")
    public ResponseEntity<String> applyCoupon(@RequestParam String couponCode, @RequestParam String orderId) {
        boolean applied = couponService.applyCouponToOrder(couponCode, orderId);

        if (applied) {
            return new ResponseEntity<>("Coupon applied successfully", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Failed to apply coupon", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCoupon(@PathVariable String id) {
        couponService.deleteCoupon(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}