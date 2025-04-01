import 'dart:io' show Platform;

class ApiConstants {
  // Base URLs for different environments
  static const String localEmulatorUrl = 'http://10.0.2.2:8080';
  static const String localUrl = 'http://localhost:8080';
  
  // Chọn base URL phù hợp theo môi trường
  static String get baseApiUrl {
    // Cho môi trường development
    if (Platform.isAndroid) {
      return localEmulatorUrl; // Cho Android emulator
    } else {
      return localUrl; // Cho web, iOS và các nền tảng khác
    }
  }
} 