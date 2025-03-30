import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  String _username = '';

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  String get username => _username;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    final userDataString = prefs.getString('user_data');
    
    if (_token != null && userDataString != null) {
      _isAuthenticated = true;
      try {
        _userData = jsonDecode(userDataString);
        _username = _userData?['username'] ?? '';
      } catch (e) {
        print('Lỗi khi parse userData: $e');
      }
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _errorMessage = null;
      final authService = AuthService();
      final result = await authService.login(username, password);
      
      if (result['success']) {
        _token = result['token'];
        _userData = result['user'];
        _username = _userData?['username'] ?? username;
        _isAuthenticated = true;
        
        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        if (_userData != null) {
          await prefs.setString('user_data', jsonEncode(_userData));
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng nhập thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _errorMessage = null;
      final authService = AuthService();
      final result = await authService.register(username, email, password);
      
      if (result['success']) {
        // Đăng ký thành công, có thể tự động đăng nhập
        // hoặc để người dùng đăng nhập
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng ký thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userData = null;
    _isAuthenticated = false;
    _username = '';
    
    // Xóa dữ liệu từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    
    notifyListeners();
  }
} 