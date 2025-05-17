package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Coupon;
import com.example.ecommerceproject.repository.CouponRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.HashMap;

@Service
public class CouponService {

    @Autowired
    private CouponRepository couponRepository;

    // Thêm coupon mới
    public Coupon createCoupon(Coupon coupon) {
        return couponRepository.save(coupon);
    }

    // Lấy tất cả coupon
    public List<Coupon> getAllCoupons() {
        return couponRepository.findAll();
    }

    // Lấy coupon theo id
    public Coupon getCouponById(String id) {
        return couponRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy coupon với id: " + id));
    }

    // Lấy coupon theo code
    public Coupon getCouponByCode(String code) {
        return couponRepository.findByCode(code)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy coupon với code: " + code));
    }

    // Kiểm tra coupon có hợp lệ không
    public boolean validateCoupon(String code) {
        try {
            Coupon coupon = getCouponByCode(code);
            return coupon.isValid();
        } catch (Exception e) {
            return false;
        }
    }

    // Lấy thông tin chi tiết về coupon
    public Map<String, Object> getCouponDetails(String code) {
        Map<String, Object> details = new HashMap<>();
        try {
            Coupon coupon = getCouponByCode(code);
            details.put("valid", coupon.isValid());
            details.put("code", coupon.getCode());
            details.put("value", coupon.getValue());
            details.put("remainingUses", coupon.getMaxUses() - coupon.getUsedCount());
            return details;
        } catch (Exception e) {
            details.put("valid", false);
            details.put("message", "Coupon không tồn tại");
            return details;
        }
    }

    // Áp dụng coupon vào order
    public boolean applyCouponToOrder(String code, String orderId) {
        try {
            Coupon coupon = getCouponByCode(code);
            boolean applied = coupon.applyToOrder(orderId);
            if (applied) {
                couponRepository.save(coupon);
            }
            return applied;
        } catch (Exception e) {
            return false;
        }
    }

    // Cập nhật coupon
    public Coupon updateCoupon(Coupon coupon) {
        return couponRepository.save(coupon);
    }

    // Xóa coupon
    public void deleteCoupon(String id) {
        couponRepository.deleteById(id);
    }
}