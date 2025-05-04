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
  int _userRole = 0; // 0 = user, 1 = admin

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  int get userRole => _userRole;

  // Kiểm tra trạng thái đăng nhập từ SharedPreferences
  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('admin_token');

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
  }

  // Đăng nhập
  Future<bool> login(String username, String password) async {
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
          _errorMessage = null;

          // Lưu thông tin đăng nhập
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_token', _token!);
          await prefs.setString('admin_user_data', jsonEncode(_userData));

          notifyListeners();
          return true;
        }
      }

      _errorMessage = data['message'] ?? 'Đăng nhập thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Kiểm tra quyền admin
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
