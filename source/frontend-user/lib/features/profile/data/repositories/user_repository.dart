import 'dart:convert' show json, jsonDecode, jsonEncode, utf8;
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        throw Exception('Không tìm thấy thông tin đăng nhập');
      }

      // Gọi API để lấy thông tin người dùng
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/get/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      print('User API response: ${response.body}');

      // Xử lý response với UTF-8
      final String responseBody = utf8.decode(response.bodyBytes);
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        return responseData['data'];
      } else {
        throw Exception(
            responseData['message'] ?? 'Không thể tải thông tin người dùng');
      }
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      // Đảm bảo encode UTF-8 đúng cách
      final String encodedData = json.encode(updatedData);

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/user/edit/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: encodedData,
      );

      // Xử lý response với UTF-8
      final String responseBody = utf8.decode(response.bodyBytes);
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        return true;
      } else {
        throw Exception(
            responseData['message'] ?? 'Không thể cập nhật thông tin');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
