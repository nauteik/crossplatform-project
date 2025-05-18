import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base URLs for different environments
  static const String localEmulatorUrl = 'https://hkt-backend-a2bb8a1df288.herokuapp.com';
  static const String localUrl = 'https://hkt-backend-a2bb8a1df288.herokuapp.com';
  // static const String localEmulatorUrl = 'http://10.0.2.2:8080';
  // static const String localUrl = 'http://localhost:8080';
  
  // Chọn base URL phù hợp theo môi trường
  static String get baseApiUrl {
    // Kiểm tra nếu đang chạy trên web
    if (kIsWeb) {
      return localUrl;
    }
    
    // Cho môi trường development
    try {
      if (Platform.isAndroid) {
        return localEmulatorUrl; // Cho Android emulator
      } else {
        return localUrl; // Cho iOS và các nền tảng khác
      }
    } catch (e) {
      // Fallback nếu không thể xác định Platform
      return localUrl;
    }
  }

  // Thêm getter cho baseUrl để tương thích với code hiện tại
  static String get baseUrl {
    return baseApiUrl + '/api';
  }
}