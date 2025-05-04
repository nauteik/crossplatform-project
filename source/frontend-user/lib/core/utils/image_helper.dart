import 'package:frontend_user/core/constants/api_constants.dart';

class ImageHelper {
  static String getImage(String imageName) {
    if (imageName.isEmpty) return '';
    
    // Thêm tham số timestamp vào URL để tránh cache
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${ApiConstants.baseApiUrl}/api/images/$imageName?t=$timestamp';
  }
}
