import 'package:frontend_user/core/constants/api_constants.dart';

class ImageHelper {
  static String getImage(String imageName) {
    if (imageName.isEmpty) return '';
    return '${ApiConstants.baseApiUrl}/api/images/$imageName';
  }
}
