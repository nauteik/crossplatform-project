package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Coupon;
import com.example.ecommerceproject.repository.CouponRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CouponService {

    private final CouponRepository couponRepository;

    @Autowired
    public CouponService(CouponRepository couponRepository) {
        this.couponRepository = couponRepository;
    }

    // Thêm coupon mới
    public Coupon createCoupon(Coupon coupon) {
        return couponRepository.save(coupon);
    }

    // Lấy tất cả coupon
    public List<Coupon> getAllCoupons() {
        return couponRepository.findAll();
    }

    // Tìm coupon theo ID
    public Optional<Coupon> getCouponById(String id) {
        return couponRepository.findById(id);
    }

    // Tìm coupon theo code
    public Optional<Coupon> getCouponByCode(String code) {
        return couponRepository.findByCode(code);
    }

    // Áp dụng coupon vào đơn hàng
    public boolean applyCouponToOrder(String couponCode, String orderId) {
        Optional<Coupon> optionalCoupon = couponRepository.findByCode(couponCode);

        if (optionalCoupon.isPresent()) {
            Coupon coupon = optionalCoupon.get();
            if (coupon.applyToOrder(orderId)) {
                couponRepository.save(coupon);
                return true;
            }
        }

        return false;
    }

    // Xóa coupon
    public void deleteCoupon(String id) {
        couponRepository.deleteById(id);
    }
}