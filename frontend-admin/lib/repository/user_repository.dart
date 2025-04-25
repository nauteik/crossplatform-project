// lib/users_management_repository.dart
import 'dart:convert';
import 'package:admin_interface/constants/api_constants.dart';
import 'package:admin_interface/models/api_response_model.dart';
import 'package:admin_interface/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserManagementRepository {
  final String _baseUrl = "${ApiConstants.baseApiUrl}/user";

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer YOUR_JWT_TOKEN_HERE', // Thêm token nếu cần
  };

  // --- Lấy danh sách người dùng (GET /user/getAll) ---
  Future<ApiResponse<List<User>>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getAll'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Decode với UTF-8 encoding
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        List<dynamic> jsonList;
        if (responseData is Map && responseData.containsKey('data')) {
          jsonList = responseData['data'] as List;
        } else if (responseData is List) {
          jsonList = responseData;
        } else {
          throw FormatException('Định dạng phản hồi không hợp lệ');
        }

        final List<User> users = jsonList
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<User>>(
          status: 200,
          message: 'Lấy danh sách người dùng thành công',
          data: users,
        );
      } else {
         String errorMessage = 'Failed to fetch users. Status code: ${response.statusCode}';
         return ApiResponse<List<User>>(status: response.statusCode, message: errorMessage, data: []);
      }
    } catch (e) {
      print('Error fetching users: $e');
      return ApiResponse<List<User>>(status: 500, message: 'Không thể kết nối đến máy chủ. Vui lòng thử lại.', data: []);
    }
  }

  // --- Thêm người dùng mới (POST /user/add) ---
  Future<ApiResponse<User>> addUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decode với UTF-8 encoding
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final newUser = User.fromJson(jsonResponse);
        return ApiResponse<User>(
          status: response.statusCode,
          message: 'Thêm người dùng thành công',
          data: newUser,
        );
      } else {
        String errorMessage = 'Failed to add user. Status code: ${response.statusCode}';
        return ApiResponse<User>(status: response.statusCode, message: errorMessage, data: null);
      }
    } catch (e) {
       print('Error adding user: $e');
       return ApiResponse<User>(status: 500, message: 'Không thể kết nối đến máy chủ để thêm người dùng.', data: null);
    }
  }

  // --- Cập nhật thông tin người dùng (PUT /user/edit/{userId}) ---
   Future<ApiResponse<User>> updateUser(String userId, Map<String, dynamic> userData) async {
     try {
      final response = await http.put(
        Uri.parse('$_baseUrl/edit/$userId'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      final jsonResponse = jsonDecode(response.body);
      final apiResponse = ApiResponse<User>.fromJson(jsonResponse, (dataJson) => User.fromJson(dataJson));

      return apiResponse;

    } catch (e) {
       print('Error updating user: $e');
       return ApiResponse<User>(status: 500, message: 'Không thể kết nối đến máy chủ để cập nhật người dùng.', data: null);
    }
  }

  // --- Xóa người dùng (Endpoint KHÔNG CÓ trong UserController.txt) ---
   Future<ApiResponse<dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$userId'),
        headers: _headers,
      );

      final jsonResponse = jsonDecode(response.body);
      final apiResponse = ApiResponse<dynamic>.fromJson(jsonResponse, (dataJson) => null);

      return apiResponse;

    } catch (e) {
       print('Error deleting user: $e');
       return ApiResponse<dynamic>(status: 500, message: 'Không thể kết nối đến máy chủ để xóa người dùng.', data: null);
    }
  }

   // --- Lấy thông tin người dùng theo ID (GET /user/get/{userId}) ---
  Future<ApiResponse<User>> getUserById(String userId) async {
     try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get/$userId'),
        headers: _headers,
      );

      final jsonResponse = jsonDecode(response.body);
      final apiResponse = ApiResponse<User>.fromJson(jsonResponse, (dataJson) => User.fromJson(dataJson));

      return apiResponse;

    } catch (e) {
       print('Error getting user by ID: $e');
       return ApiResponse<User>(status: 500, message: 'Không thể kết nối đến máy chủ để lấy thông tin người dùng.', data: null);
    }
  }

   // --- Lấy thông tin người dùng hiện tại (GET /user/me) ---
  Future<ApiResponse<User>> getCurrentUser(String jwtToken) async {
     try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $jwtToken',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      final apiResponse = ApiResponse<User>.fromJson(jsonResponse, (dataJson) => User.fromJson(dataJson));

      return apiResponse;

    } catch (e) {
       print('Error getting current user: $e');
       return ApiResponse<User>(status: 500, message: 'Không thể kết nối đến máy chủ để lấy thông tin người dùng hiện tại.', data: null);
    }
  }
}