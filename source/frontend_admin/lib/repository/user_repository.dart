import 'dart:convert';
import 'package:frontend_admin/constants/api_constants.dart';
import 'package:frontend_admin/models/api_response_model.dart';
import 'package:frontend_admin/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementRepository {
  final String _baseUrl =
      "${ApiConstants.baseApiUrl}/api/user";

  // Cập nhật để lấy token từ SharedPreferences
  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // --- Lấy danh sách người dùng (GET /user/getAll) ---
  Future<ApiResponse<List<User>>> fetchUsers() async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/getAll'),
        headers: headers,
      );

      final responseString = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseString);
      print(
        'Fetch users response (${response.statusCode}): $responseString',
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList;
        if (responseData is Map && responseData.containsKey('data')) {
          jsonList = responseData['data'] as List;
        } else if (responseData is List) {
          jsonList = responseData;
        } else {
          if (responseData is Map &&
              (responseData.containsKey('data') &&
                  responseData['data'] == null)) {
            jsonList = [];
          } else {
            print('Unexpected response format: $responseData');
            throw FormatException(
              'Định dạng phản hồi không hợp lệ từ máy chủ.',
            );
          }
        }

        final List<User> users =
            jsonList
                .where(
                  (item) => item != null && item is Map<String, dynamic>,
                ) // Lọc bỏ các item null hoặc không phải Map
                .map(
                  (item) => User.fromJson(item as Map<String, dynamic>),
                ) // Sử dụng User.fromJson đã cập nhật
                .toList();

        // Kiểm tra message từ API nếu có
        final message =
            responseData is Map && responseData.containsKey('message')
                ? responseData['message']
                : 'Lấy danh sách người dùng thành công';

        return ApiResponse<List<User>>(
          status: response.statusCode,
          message: message,
          data: users,
        );
      } else {
        // Xử lý lỗi từ phản hồi API
        String errorMessage =
            responseData is Map && responseData.containsKey('message')
                ? responseData['message']
                : 'Lỗi khi lấy danh sách người dùng. Status code: ${response.statusCode}';
        print('API Error fetchUsers: $errorMessage');
        return ApiResponse<List<User>>(
          status: response.statusCode,
          message: errorMessage,
          data: [],
        );
      }
    } catch (e) {
      print('Exception fetching users: $e');
      return ApiResponse<List<User>>(
        status: 500,
        message: 'Không thể kết nối đến máy chủ hoặc xử lý dữ liệu.',
        data: [],
      );
    }
  }

  // --- Thêm người dùng mới (POST /user/add) ---
  Future<ApiResponse<User>> addUser(Map<String, dynamic> userData) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('$_baseUrl/add'),
        headers: headers,
        body: jsonEncode(userData), 
      );

      final responseString = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(responseString);
      print(
        'Add user response (${response.statusCode}): $responseString',
      ); 

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse is Map<String, dynamic>) {
          final userDataJson =
              jsonResponse['data'] ??
              jsonResponse; 
          final newUser = User.fromJson(
            userDataJson,
          ); // Sử dụng User.fromJson đã cập nhật
          final message =
              jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Thêm người dùng thành công';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: newUser,
          );
        } else {
          // Nếu API không trả về đối tượng User mà chỉ là message thành công
          final message =
              jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Thêm người dùng thành công';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: null, // Không có dữ liệu User trả về
          );
        }
      } else {
        String errorMessage =
            jsonResponse is Map && jsonResponse.containsKey('message')
                ? jsonResponse['message']
                : 'Lỗi khi thêm người dùng. Status code: ${response.statusCode}';
        print('API Error addUser: $errorMessage');
        return ApiResponse<User>(
          status: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      print('Exception adding user: $e');
      return ApiResponse<User>(
        status: 500,
        message: 'Không thể kết nối đến máy chủ để thêm người dùng.',
        data: null,
      );
    }
  }

  // --- Cập nhật thông tin người dùng (PUT /user/edit/{userId}) ---
  Future<ApiResponse<User>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final headers = await _headers;
      final response = await http.put(
        Uri.parse('$_baseUrl/edit/$userId'),
        headers: headers,
        body: jsonEncode(userData), 
      );

      final responseString = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(responseString);
      print(
        'Update user response (${response.statusCode}): $responseString',
      ); 

      if (response.statusCode == 200) {
        // API trả về User đã cập nhật?
        if (jsonResponse is Map<String, dynamic>) {
          final userDataJson =
              jsonResponse['data'] ??
              jsonResponse; 
          final updatedUser = User.fromJson(
            userDataJson,
          ); // Sử dụng User.fromJson đã cập nhật
          final message =
              jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Cập nhật người dùng thành công';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: updatedUser,
          );
        } else {
          final message =
              jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Cập nhật người dùng thành công';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: null, // Không có dữ liệu User trả về
          );
        }
      } else {
        String errorMessage =
            jsonResponse is Map && jsonResponse.containsKey('message')
                ? jsonResponse['message']
                : 'Lỗi khi cập nhật người dùng. Status code: ${response.statusCode}';
        print('API Error updateUser: $errorMessage');
        return ApiResponse<User>(
          status: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      print('Exception updating user: $e');
      return ApiResponse<User>(
        status: 500,
        message: 'Không thể kết nối đến máy chủ để cập nhật người dùng.',
        data: null,
      );
    }
  }

  // --- Xóa người dùng (DELETE /user/delete/{userId}) ---
  Future<ApiResponse<dynamic>> deleteUser(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$userId'),
        headers: headers,
      );

      final responseString = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(responseString);
      print(
        'Delete user response (${response.statusCode}): $responseString',
      ); 

      if (response.statusCode == 200) {
        final message =
            jsonResponse is Map && jsonResponse.containsKey('message')
                ? jsonResponse['message']
                : 'Xóa người dùng thành công';
        return ApiResponse<dynamic>(
          status: response.statusCode,
          message: message,
          data: null,
        );
      } else {
        String errorMessage =
            jsonResponse is Map && jsonResponse.containsKey('message')
                ? jsonResponse['message']
                : 'Lỗi khi xóa người dùng. Status code: ${response.statusCode}';
        print('API Error deleteUser: $errorMessage');
        return ApiResponse<dynamic>(
          status: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      print('Exception deleting user: $e');
      return ApiResponse<dynamic>(
        status: 500,
        message: 'Không thể kết nối đến máy chủ để xóa người dùng.',
        data: null,
      );
    }
  }

  // --- Lấy thông tin người dùng theo ID (GET /user/get/{userId}) ---
  Future<ApiResponse<User>> getUserById(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/get/$userId'),
        headers: headers,
      );

      final responseString = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(responseString);
      print(
        'Get user by ID response (${response.statusCode}): $responseString',
      ); 

      if (response.statusCode == 200) {
        if (jsonResponse is Map<String, dynamic>) {
          
          final userDataJson =
              jsonResponse['data'] ??
              jsonResponse; 
          final user = User.fromJson(
            userDataJson,
          ); // Sử dụng User.fromJson đã cập nhật
          final message =
              jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Lấy thông tin người dùng thành công';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: user,
          );
        } else {
          final message =
              jsonResponse is Map && jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Lấy thông tin người dùng thành công (không có dữ liệu).';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: null,
          );
        }
      } else {
        String errorMessage =
            jsonResponse is Map && jsonResponse.containsKey('message')
                ? jsonResponse['message']
                : 'Lỗi khi lấy thông tin người dùng. Status code: ${response.statusCode}';
        print('API Error getUserById: $errorMessage');
        return ApiResponse<User>(
          status: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      print('Exception getting user by ID: $e');
      return ApiResponse<User>(
        status: 500,
        message: 'Không thể kết nối đến máy chủ để lấy thông tin người dùng.',
        data: null,
      );
    }
  }

  // --- Lấy thông tin người dùng hiện tại (GET /user/me) ---
  // Cần truyền token vào hàm này nếu endpoint /me yêu cầu
  Future<ApiResponse<User>> getCurrentUser() async {
    // Bỏ tham số jwtToken nếu headers đã lấy
    try {
      final headers = await _headers; // Lấy token từ headers
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: headers,
      );

      final responseString = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(responseString);
      print(
        'Get current user response (${response.statusCode}): $responseString',
      ); 

      if (response.statusCode == 200) {
        if (jsonResponse is Map<String, dynamic>) {
          
          final userDataJson =
              jsonResponse['data'] ??
              jsonResponse; 
          final currentUser = User.fromJson(
            userDataJson,
          ); // Sử dụng User.fromJson đã cập nhật
          final message =
              jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Lấy thông tin người dùng hiện tại thành công';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: currentUser,
          );
        } else {
          final message =
              jsonResponse is Map && jsonResponse.containsKey('message')
                  ? jsonResponse['message']
                  : 'Lấy thông tin người dùng hiện tại thành công (không có dữ liệu).';
          return ApiResponse<User>(
            status: response.statusCode,
            message: message,
            data: null,
          );
        }
      } else {
        String errorMessage =
            jsonResponse is Map && jsonResponse.containsKey('message')
                ? jsonResponse['message']
                : 'Lỗi khi lấy thông tin người dùng hiện tại. Status code: ${response.statusCode}';
        print('API Error getCurrentUser: $errorMessage');
        return ApiResponse<User>(
          status: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      print('Exception getting current user: $e');
      return ApiResponse<User>(
        status: 500,
        message:
            'Không thể kết nối đến máy chủ để lấy thông tin người dùng hiện tại.',
        data: null,
      );
    }
  }
}
