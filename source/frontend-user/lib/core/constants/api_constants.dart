import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base URLs for different environments
  
  //Real Android url
  static const String localEmulatorUrl = 'http://10.0.2.2:8080';
  // static const String localEmulatorUrl = 'http://192.168.1.3:8080';
  static const String localUrl = 'http://localhost:8080';
  static const String fallbackUrl = 'http://10.0.2.2:8080'; // Fallback URL nếu không kết nối được

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
      } else if (Platform.isIOS) {
        return localUrl; // Cho iOS simulator
      } else {
        return localUrl; // Cho các nền tảng khác
      }
    } catch (e) {
      // Fallback nếu không thể xác định Platform
      return fallbackUrl;
    }
  }

  // Thêm getter cho baseUrl để tương thích với code hiện tại
  static String get baseUrl {
    return baseApiUrl + '/api';
  }
}
