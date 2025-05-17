import 'package:frontend_user/core/constants/api_constants.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageHelper {
  // Giữ nguyên phương thức getImage
  static String getImage(String imageName) {
    if (imageName.isEmpty) return '';

    // Thêm tham số timestamp vào URL để tránh cache
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${ApiConstants.baseApiUrl}/api/images/$imageName?t=$timestamp';
  }

  static String getMediaUrl(String path) {
    if (path.isEmpty) return '';

    // Log cho việc debug
    print('📸 Original media path: $path');

    String result;

    if (path.startsWith('http')) {
      result = path;
    } else if (path.startsWith('/')) {
      // Xác định baseUrl dựa trên môi trường
      String baseUrl = _getAppropriateBaseUrl();

      // Loại bỏ '/api' nếu có
      if (baseUrl.endsWith('/api')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 4);
      }

      result = '$baseUrl$path';
    } else {
      // Xác định baseUrl dựa trên môi trường
      String baseUrl = _getAppropriateBaseUrl();

      // Loại bỏ '/api' nếu có
      if (baseUrl.endsWith('/api')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 4);
      }

      result = '$baseUrl/$path';
    }

    print('🔗 Transformed media URL: $result');
    return result;
  }

  // Phương thức helper để xác định URL phù hợp dựa trên môi trường
  static String _getAppropriateBaseUrl() {
    if (kIsWeb) {
      return ApiConstants.localUrl;
    } else if (Platform.isAndroid) {
      // Sử dụng biến toàn cục hoặc cấu hình để xác định đang chạy trên thiết bị nào
      bool isEmulator = _isRunningOnEmulator();

      if (isEmulator) {
        print('📱 Running on Android Emulator, using 10.0.2.2');
        return ApiConstants.localEmulatorUrl;
      } else {
        print('📱 Running on Android Device, using device IP');
        return ApiConstants.localDeviceUrl; // Cấu hình trong ApiConstants
      }
    } else if (Platform.isIOS) {
      bool isSimulator = _isRunningOnSimulator();

      if (isSimulator) {
        print('📱 Running on iOS Simulator, using localhost');
        return ApiConstants.localUrl;
      } else {
        print('📱 Running on iOS Device, using device IP');
        return ApiConstants.localDeviceUrl;
      }
    }

    return ApiConstants.baseUrl;
  }

  // Phương thức để kiểm tra xem đang chạy trên emulator không
  static bool _isRunningOnEmulator() {
    // Đây là ước lượng đơn giản
    // Trong thực tế, bạn có thể cần sử dụng package như device_info_plus để xác định
    try {
      return Platform.environment.containsKey('ANDROID_EMULATOR');
    } catch (e) {
      // Fallback: Đặt true/false thủ công dựa vào thiết bị bạn đang chạy
      // true = đang chạy trên emulator
      // false = đang chạy trên thiết bị thật
      return false;
    }
  }

  // Phương thức để kiểm tra xem đang chạy trên iOS simulator không
  static bool _isRunningOnSimulator() {
    try {
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
    } catch (e) {
      return false;
    }
  }
}
