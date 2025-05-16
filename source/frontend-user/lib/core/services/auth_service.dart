import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_user/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  final String baseUrl = "${ApiConstants.baseApiUrl}/api/auth";

  // Phương thức tĩnh để lấy ID người dùng hiện tại từ local storage
  static Future<String?> getCurrentUserId() async {
    // Đọc từ SharedPreferences (cần đảm bảo đã lưu ID khi đăng nhập)
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print("Error getting current user ID from SharedPreferences: $e");
      // Return null or throw an exception if the ID cannot be retrieved
      return null;
    }
  }

  // Lưu token và userId
  static Future<void> saveAuthInfo(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  // Lấy token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Lấy userId
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Xóa token và userId (đăng xuất)
  static Future<void> clearAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Kiểm tra xem người dùng đã đăng nhập chưa
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/local"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Login response: $responseData"); // Debug print to see response

        // Access the token from the nested structure
        final String? token =
            responseData['data'] != null ? responseData['data']['token'] : null;

        final userData = responseData['data'] ?? {"username": username};

        // Lưu thông tin người dùng khi đăng nhập thành công
        if (userData != null && userData['id'] != null) {
          await saveAuthInfo(token ?? "", userData['id']);
        }

        print("Token extracted: ${token != null ? 'Success' : 'Null'}");

        return {
          "success": true,
          "message": "Login successful",
          "token":
              token ?? "temp_token_${DateTime.now().millisecondsSinceEpoch}",
          "user": userData
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message":
              data['message'] ?? "Login failed. Please check your credentials."
        };
      }
    } catch (e) {
      print("Network error during login: $e");
      return {
        "success": false,
        "message": "Network error: Could not connect to server"
      };
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );
      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully"};
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Registration failed"
        };
      }
    } catch (e) {
      print("Network error: $e");
      return {
        "success": false,
        "message": "Network error: Could not connect to server"
      };
    }
  }

  // Phương thức đăng xuất
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      print("Error during logout: $e");
    }
  }
}
