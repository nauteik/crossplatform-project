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

  // Check if user is already logged in from stored token
  Future<void> checkLoginStatus() async {
    if (_initialized) return;
    
    _isLoading = true;
    // Don't call notifyListeners() here to avoid build-time updates

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');

    if (storedToken != null && !_isTokenExpired(storedToken)) {
      _token = storedToken;
      _extractUserFromToken(storedToken);
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

          // Extract user from token
          _extractUserFromToken(_token!);

          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('auth_token', _token!);

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

  bool isAdmin() {
    return _currentUser?.role == 1;
  }
}
