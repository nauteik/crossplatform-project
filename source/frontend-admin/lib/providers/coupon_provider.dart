// lib/providers/coupon_provider.dart
import 'package:admin_interface/models/coupon_model.dart';
import 'package:admin_interface/repository/coupon_repository.dart';
import 'package:flutter/material.dart';

class CouponProvider with ChangeNotifier {
  final CouponRepository _CouponRepository = CouponRepository();

  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Load coupons initially or refresh the list
  Future<void> loadCoupons() async {
    if (_isLoading) return; // Prevent multiple loads at once

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _coupons = await _CouponRepository.fetchCoupons();
      _coupons.sort((a, b) => b.creationTime.compareTo(a.creationTime)); // Sort after fetching
    } catch (e) {
      _errorMessage = 'Lỗi khi tải mã giảm giá: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new coupon
  Future<void> addCoupon({
    required String code,
    required int value,
    required int maxUses,
  }) async {
    // Business validation (can also be done in UI before calling provider)
    if (code.isEmpty || code.length != 5 || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(code)) {
       throw Exception('Mã giảm giá phải là chuỗi 5 ký tự chữ/số.');
    }
    if (maxUses <= 0 || maxUses > 10) { // Max uses up to 10 as per requirements, though backend allows 100 in sample JSON
        // Decide whether to validate against requirements (10) or backend's current limit (100)
        // Let's stick to the requirements (10) as per document page 5.
       throw Exception('Số lượt dùng tối đa phải là số nguyên dương từ 1 đến 10.');
    }
     if (![10000, 20000, 50000, 100000].contains(value)) { // Allowed values as per requirements
        throw Exception('Giá trị giảm giá không hợp lệ.');
     }

    _isLoading = true; // Indicate adding is in progress
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      // Call repository method - it handles the API call and parsing response
      final newCoupon = await _CouponRepository.addCoupon(code, value, maxUses);

      // Add the newly created coupon (includes ID, creationTime from backend) to the list
      _coupons.add(newCoupon);
      _coupons.sort((a, b) => b.creationTime.compareTo(a.creationTime)); // Re-sort after adding

    } catch (e) {
      _errorMessage = 'Lỗi khi thêm mã giảm giá: ${e.toString()}';
      print(_errorMessage);
       rethrow; // Re-throw to let UI handle specific error messages if needed (e.g., SnackBar)
    } finally {
       _isLoading = false; // Adding finished
       notifyListeners(); // Update UI
    }
  }

  // Delete a coupon
   Future<void> deleteCoupon(String couponId) async {
      _isLoading = true; // Indicate deleting is in progress
      _errorMessage = null; // Clear previous errors
      notifyListeners(); // Optional: show loading indicator for the whole list during deletion

      try {
         // Call repository method
         await _CouponRepository.deleteCoupon(couponId);

         // Remove the coupon from the local list
         _coupons.removeWhere((coupon) => coupon.id == couponId);
         // No need to sort after deletion if you use removeWhere

      } catch (e) {
         _errorMessage = 'Lỗi khi xóa mã giảm giá: ${e.toString()}';
         print(_errorMessage);
          rethrow; // Re-throw for UI to handle error display
      } finally {
          _isLoading = false; // Deletion finished
          notifyListeners(); // Update UI
      }
   }

  // You can add other methods like getCouponById if needed elsewhere
  // Future<Coupon?> getCouponById(String id) {
  //    // This would call _CouponRepository.getCouponById(id) if implemented
  //    // For the list view, you likely don't need this.
  // }
}