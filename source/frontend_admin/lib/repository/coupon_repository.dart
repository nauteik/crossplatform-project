import 'dart:convert';

import 'package:frontend_admin/constants/api_constants.dart';
import 'package:frontend_admin/models/coupon_model.dart';
import 'package:http/http.dart' as http;

class CouponRepository {
  final String _baseUrl = "${ApiConstants.baseApiUrl}/api/coupons";

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Coupon>> fetchCoupons() async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final String rawResponseBody = utf8.decode(response.bodyBytes);

        // Đảm bảo xử lý response đúng cấu trúc API chuẩn
        final dynamic decodedBody = jsonDecode(rawResponseBody);
        
        // Xử lý cấu trúc ApiResponse
        if (decodedBody is Map && decodedBody.containsKey('data')) {
          final dynamic data = decodedBody['data'];
          if (data is List) {
            return data.map((json) => Coupon.fromJson(json)).toList();
          } else {
            print('Unexpected response data format: Not a List');
            throw Exception('Dữ liệu mã giảm giá trả về không hợp lệ.');
          }
        } 
        // Trường hợp API trả về trực tiếp List
        else if (decodedBody is List) {
          return decodedBody.map((json) => Coupon.fromJson(json)).toList();
        } 
        else {
          print('Unexpected response format: Neither ApiResponse nor List');
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
      rethrow;
    }
  }

  Future<Coupon> addCoupon(String code, double value, int maxUses) async {
    final uri = Uri.parse(_baseUrl);

    // Tạo đối tượng Coupon tạm thời chỉ để dùng toJsonForCreation
    final tempCoupon = Coupon(
      id: '', 
      code: code.toUpperCase(),
      value: value,
      maxUses: maxUses,
      usedCount: 0,
      creationTime: DateTime.now(),
      ordersApplied: [],
      valid: true,
    );

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(
          tempCoupon.toJsonForCreation(),
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final String rawResponseBody = utf8.decode(response.bodyBytes);
        final dynamic decodedData = jsonDecode(rawResponseBody);
        
        // Xử lý cấu trúc ApiResponse
        if (decodedData is Map && decodedData.containsKey('data')) {
          return Coupon.fromJson(Map<String, dynamic>.from(decodedData['data']));
        }
        // Trường hợp API trả về trực tiếp đối tượng Coupon
        else if (decodedData is Map) {
          return Coupon.fromJson(Map<String, dynamic>.from(decodedData));
        }
        else {
          throw Exception('Dữ liệu coupon trả về không hợp lệ');
        }
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
