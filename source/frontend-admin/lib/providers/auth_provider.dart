import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:admin_interface/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_interface/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token;
  String? _errorMessage;
  User? _currentUser;
  bool _initialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get initialized => _initialized;
  String? get userId => _currentUser?.id;

  // Check if user is already logged in from stored token
  Future<void> checkLoginStatus() async {
    if (_initialized) return;
    
    _isLoading = true;
    // Don't call notifyListeners() here to avoid build-time updates

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUserId = prefs.getString('admin_id');

    if (storedToken != null && !_isTokenExpired(storedToken)) {
      _token = storedToken;
      _extractUserFromToken(storedToken);
      
      // Nếu không có thông tin user từ token, thử lấy từ userId đã lưu
      if (_currentUser == null && storedUserId != null) {
        // Tạo một user đơn giản với ID đã lưu trước đó
        _currentUser = User(
          id: storedUserId,
          email: prefs.getString('admin_email') ?? '',
          name: prefs.getString('admin_name') ?? '',
          role: 1, // Admin role
        );
        
      }
      
      _isLoggedIn = true;
    }

    _isLoading = false;
    _initialized = true;
    // Now we can notify after the initialization is complete
    notifyListeners();
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login/local'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['status'] == 200) {
        final data = responseData['data'];
        if (data != null && data['token'] != null) {
          _token = data['token'];

          // Tạo user object từ dữ liệu JSON trả về thay vì từ token
          _currentUser = User(
            id: data['id'] ?? '',
            email: data['email'] ?? '',
            name: data['name'] ?? '',
            username: data['username'] ?? username,
            role: data['role'] ?? 0,
          );
          


          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('auth_token', _token!);
          
          // Lưu thông tin admin ID để sử dụng sau này
          if (_currentUser != null) {
            prefs.setString('admin_id', _currentUser!.id);
            prefs.setString('admin_email', _currentUser!.email);
            prefs.setString('admin_name', _currentUser!.name);
            
          }

          _isLoggedIn = true;
          _isLoading = false;
          _initialized = true;
          notifyListeners();
          return true;
        }
      }

      _errorMessage = responseData['message'] ?? 'Đăng nhập thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Đăng nhập thất bại: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user and clear token
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');
    prefs.remove('admin_id');
    prefs.remove('admin_email');
    prefs.remove('admin_name');

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
        id: decodedToken['id'] ?? decodedToken['sub'] ?? '',
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

  bool isAdmin() {
    return _currentUser?.role == 1;
  }

  // Hiển thị thông tin admin hiện tại (debugging)
  void printCurrentAdminInfo() {
    print('Current Admin: ${_currentUser?.toJson()}');
  }
}
