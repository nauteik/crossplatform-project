import 'dart:convert';

import 'package:frontend_admin/constants/api_constants.dart';
import 'package:frontend_admin/models/coupon_model.dart';
import 'package:http/http.dart' as http;

class CouponRepository {
  final String _baseUrl = "${ApiConstants.baseApiUrl}/api/coupon";

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Coupon>> fetchCoupons() async {
    final uri = Uri.parse('$_baseUrl/coupons');

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final String rawResponseBody = utf8.decode(response.bodyBytes);

        // Ensure the response body is indeed a JSON array
        final dynamic decodedBody = jsonDecode(rawResponseBody);
        if (decodedBody is List) {
          return decodedBody.map((json) => Coupon.fromJson(json)).toList();
        } else {
          // Handle case where backend returns non-list for /coupons endpoint
          print('Unexpected response format for /coupons: Not a List');
          throw Exception('Dữ liệu mã giảm giá trả về không hợp lệ.');
        }
      } else {
        print('Failed to fetch coupons: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Không thể tải danh sách mã giảm giá. Lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching coupons: $e');
      // Rethrowing caught exceptions is often better to let the Provider handle them
      rethrow;
    }
  }

  Future<Coupon> addCoupon(String code, int value, int maxUses) async {
    final uri = Uri.parse(_baseUrl); // <-- Đã sửa thành /api/coupon

    // Tạo đối tượng Coupon tạm thời chỉ để dùng toJsonForCreation
    // Các trường khác (id, usedCount, creationTime, ordersApplied, valid) không cần thiết ở đây
    final tempCoupon = Coupon(
      id: '', // Dummy ID
      code: code.toUpperCase(),
      value: value,
      maxUses: maxUses,
      usedCount: 0, // Dummy
      creationTime: DateTime.now(), // Dummy
      ordersApplied: [], // Dummy
      valid: true, // Dummy
    );

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(
          tempCoupon.toJsonForCreation(),
        ), // <-- Sử dụng toJsonForCreation
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        // Backend should return the complete created coupon including ID and creationTime
        return Coupon.fromJson(responseData);
      } else {
        print('Failed to add coupon: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
        throw Exception(
          'Không thể thêm mã giảm giá. Lỗi: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      print('Error adding coupon: $e');
      rethrow;
    }
  }

  // Thêm phương thức xóa coupon DELETE /api/coupon/{id}
  Future<void> deleteCoupon(String couponId) async {
    final uri = Uri.parse('$_baseUrl/$couponId'); // <-- Endpoint DELETE /{id}

    try {
      final response = await http.delete(uri, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Assuming 200 OK or 204 No Content on success
        print('Coupon $couponId deleted successfully');
      } else {
        print('Failed to delete coupon $couponId: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
        throw Exception(
          'Không thể xóa mã giảm giá $couponId. Lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error deleting coupon $couponId: $e');
      rethrow;
    }
  }
}
