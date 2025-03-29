import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://localhost:8080/api/auth";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Login response: $responseData"); // Debug print to see response

        // Access the token from the nested structure
        final String? token =
            responseData['data'] != null ? responseData['data']['token'] : null;

        final userData = responseData['data'] ?? {"username": username};

        print("Token extracted: ${token != null ? 'Success' : 'Null'}");

        return {
          "success": true,
          "message": "Login successful",
          "token":
              token ?? "temp_token_${DateTime.now().millisecondsSinceEpoch}",
          "user": userData
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message":
              data['message'] ?? "Login failed. Please check your credentials."
        };
      }
    } catch (e) {
      print("Network error during login: $e");
      return {
        "success": false,
        "message": "Network error: Could not connect to server"
      };
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
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
    } catch (e) {
      print("Network error: $e");
      return {
        "success": false,
        "message": "Network error: Could not connect to server"
      };
    }
  }
} 