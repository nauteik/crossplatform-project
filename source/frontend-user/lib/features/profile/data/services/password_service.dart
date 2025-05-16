import 'dart:convert';
import 'package:http/http.dart' as http;

class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}

class PasswordService {
  final String baseUrl;
  final String token;

  PasswordService({
    required this.baseUrl,
    required this.token,
  });

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    // Sửa URL API cho đúng với endpoint trong UserController
    final url = Uri.parse('$baseUrl/user/change-password/$userId');

    final request = ChangePasswordRequest(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    print('Calling API: ${url.toString()}'); // Debug log

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Đổi mật khẩu thất bại');
      }
    } catch (e) {
      print('API Error: $e'); // Debug log
      throw e;
    }
  }
}
