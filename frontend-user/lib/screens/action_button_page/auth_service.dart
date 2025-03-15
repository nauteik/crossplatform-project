import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://192.168.111.147:8080/api/auth";

  Future<Map<String, dynamic>> registerUser(
      String username, String password, String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"username": username, "password": "password", "email": email}),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "User registered successfully"};
    } else {
      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": data['message'] ?? "Registration failed"
      };
    }
  }
}
