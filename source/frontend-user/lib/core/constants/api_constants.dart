import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base URLs for different environments

  //Real Android url
  // static const String localEmulatorUrl = 'http://10.0.2.2:8080';
  static const String localEmulatorUrl = 'https://crossplatform-project-1.onrender.com';

  // Thay đổi IP này thành IP của máy tính bạn vừa xác định ở bước 1
  static const String localDeviceUrl =
      // 'http://192.168.1.4:8080'; // Thay IP thực tế tại đây
      'https://crossplatform-project-1.onrender.com'; // Thay IP thực tế tại đây

  // static const String localUrl = 'http://localhost:8080';
  static const String localUrl = 'https://crossplatform-project-1.onrender.com';
  static const String fallbackUrl =
      // 'http://10.0.2.2:8080'; // Fallback URL nếu không kết nối được
      'https://crossplatform-project-1.onrender.com'; // Fallback URL nếu không kết nối được

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

  // Thêm getter cho WebSocket URL
  static String get websocketUrl {
    String httpBase =
        baseApiUrl; // Lấy base URL HTTP (ví dụ: http://localhost:8080)
    // Chuyển đổi http:// thành ws:// hoặc https:// thành wss://
    if (httpBase.startsWith('https')) {
      return httpBase.replaceFirst('https', 'wss') + '/ws';
    } else {
      return httpBase.replaceFirst('http', 'ws') + '/ws';
    }
  }

  // Thêm getter cho baseUrl để tương thích với code hiện tại
  static String get baseUrl {
    return baseApiUrl + '/api';
  }
}
