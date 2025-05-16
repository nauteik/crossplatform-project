import 'package:frontend_admin/constants/api_constants.dart';

class ImageHelper {
  static String getProductImage(String imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // Thêm timestamp để tránh cache
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Kiểm tra nếu imagePath đã là URL đầy đủ
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Thêm tham số timestamp vào URL gốc
      if (imagePath.contains('?')) {
        return imagePath + '&t=$timestamp';
      } else {
        return imagePath + '?t=$timestamp';
      }
    }
    
    // Kiểm tra nếu imagePath bắt đầu bằng /
    if (imagePath.startsWith('/')) {
      return '${ApiConstants.baseApiUrl}${imagePath}?t=$timestamp';
    }
    
    return '${ApiConstants.baseApiUrl}/api/images/${imagePath}?t=$timestamp';
  }
}