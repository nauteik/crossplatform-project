import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:admin_interface/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_interface/models/user_model.dart';
import '../constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userData;
  String? _errorMessage;
<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
  int _userRole = 0; // 0 = user, 1 = admin
=======
  User? _currentUser;
  bool _initialized = false;
>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  int get userRole => _userRole;
=======
  bool get initialized => _initialized;
>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart

  // Kiểm tra trạng thái đăng nhập từ SharedPreferences
  Future<void> checkLoginStatus() async {
<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('admin_token');
=======
    if (_initialized) return;
    
    _isLoading = true;
    // Don't call notifyListeners() here to avoid build-time updates
>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart

      if (storedToken != null) {
        _token = storedToken;

        final storedUserData = prefs.getString('admin_user_data');
        if (storedUserData != null) {
          _userData = jsonDecode(storedUserData);
          _userRole = _userData?['role'] ?? 0;
          _isLoggedIn = true;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error checking login status: $e');
    }
<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
=======

    _isLoading = false;
    _initialized = true;
    // Now we can notify after the initialization is complete
    notifyListeners();
>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart
  }

  // Đăng nhập
  Future<bool> login(String username, String password) async {
<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
=======
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final loginUrl = '${ApiConstants.baseApiUrl}/api/auth/login/local';

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print('Login response: $responseBody');
      final data = jsonDecode(responseBody);

      _isLoading = false;

      if (response.statusCode == 200 && data['status'] == 200) {
        if (data['data'] != null) {
          _token = data['data']['token'];
          _userData = data['data']['user'];
          _userRole = _userData?['role'] ?? 0;
          _isLoggedIn = true;
<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
          _errorMessage = null;

          // Lưu thông tin đăng nhập
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_token', _token!);
          await prefs.setString('admin_user_data', jsonEncode(_userData));

=======
          _isLoading = false;
          _initialized = true;
>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart
          notifyListeners();
          return true;
        }
      }

<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
      _errorMessage = data['message'] ?? 'Đăng nhập thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
=======
      _errorMessage = responseData['message'] ?? 'Đăng nhập thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Đăng nhập thất bại: $error';
      _isLoading = false;
>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart
      notifyListeners();
      return false;
    }
  }

<<<<<<< HEAD:frontend-admin/lib/providers/auth_provider.dart
  // Kiểm tra quyền admin
=======
  // Logout user and clear token
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');

    notifyListeners();
  }

  // Extract user information from JWT token
  void _extractUserFromToken(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      print('Decoded token: $decodedToken');
      // The JWT payload should contain user information
      // Adjust the fields based on your actual JWT structure
      _currentUser = User(
        id: decodedToken['sub'] ?? '',
        email: decodedToken['email'] ?? '',
        name: decodedToken['name'] ?? '',
        role: decodedToken['role'] ?? 0,
      );
    } catch (e) {
      print('Error extracting user from token: $e');
    }
  }

  // Check if token is expired
  bool _isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

>>>>>>> Kiet:source/frontend-admin/lib/providers/auth_provider.dart
  bool isAdmin() {
    return _userRole == 1;
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _token = null;
      _userData = null;
      _userRole = 0;

      // Xóa thông tin đăng nhập
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_token');
      await prefs.remove('admin_user_data');

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
