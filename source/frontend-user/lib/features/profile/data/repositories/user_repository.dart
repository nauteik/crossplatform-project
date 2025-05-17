import 'dart:convert' show json, jsonDecode, jsonEncode, utf8;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart'; // Thêm import này
import '../../../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  Future<String?> uploadAvatar(String userId, File avatarFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      print('File path: ${avatarFile.path}');
      print('File size: ${await avatarFile.length()} bytes');

      // Kiểm tra extension của file để xác định Content-Type
      String contentType = 'image/jpeg'; // Mặc định là jpeg
      if (avatarFile.path.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (avatarFile.path.toLowerCase().endsWith('.gif')) {
        contentType = 'image/gif';
      }

      // Tạo multipart request để upload file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiConstants.baseUrl}/user/upload-avatar/$userId'), // Thêm /api vào đường dẫn
      );

      // Thêm token vào header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Thêm file vào request với content-type được xác định
      final file = await http.MultipartFile.fromPath(
        'avatar',
        avatarFile.path,
        contentType: MediaType.parse(contentType), // Thêm content-type rõ ràng
      );
      request.files.add(file);

      print('Sending avatar upload request with content-type: $contentType');

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Avatar upload response status: ${response.statusCode}');
      print('Avatar upload response body: ${response.body}');

      // Xử lý response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200 && data['data'] != null) {
          return data['data']['avatar'];
        }
      }

      print('Upload avatar error: ${response.body}');
      return null;
    } catch (e) {
      print('Upload avatar exception: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      String? userId = prefs.getString('userId');

      print('Token available: ${token != null}');
      print('UserId: $userId');

      if (token == null || userId == null || userId.isEmpty) {
        print('Missing authentication information');
        return null;
      }

      print('Calling API with userId: $userId');

      // Gọi API để lấy thông tin người dùng
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/get/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('API request timed out');
          return http.Response(
              '{"status":408,"message":"Request timeout"}', 408);
        },
      );

      print('User API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Xử lý response với UTF-8
        final String responseBody = utf8.decode(response.bodyBytes);
        print('User API response body: $responseBody');

        final responseData = json.decode(responseBody);

        if (responseData['status'] == 200) {
          print('Successfully retrieved user details');
          return responseData['data'];
        } else {
          print('API Error: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      print('Updating profile for user: $userId');
      print('Update data: $updatedData');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        print('No authentication token found');
        throw Exception('Không tìm thấy token đăng nhập');
      }

      // Đảm bảo encode UTF-8 đúng cách
      final String encodedData = json.encode(updatedData);

      print(
          'Sending request to: ${ApiConstants.baseUrl}/user/edit/$userId');
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

      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: $responseBody');

      if (response.statusCode == 200 && responseData['status'] == 200) {
        // Cập nhật thông tin người dùng trong SharedPreferences
        String? userDataStr = prefs.getString('user_data');
        if (userDataStr != null) {
          Map<String, dynamic> userData = json.decode(userDataStr);
          userData.addAll(updatedData);
          await prefs.setString('user_data', json.encode(userData));
          print('Updated user data in SharedPreferences');
        }

        return true;
      } else {
        print('Error updating profile: ${responseData['message']}');
        throw Exception(
            responseData['message'] ?? 'Không thể cập nhật thông tin');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  
}
