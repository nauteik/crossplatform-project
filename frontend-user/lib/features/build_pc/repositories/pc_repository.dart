import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pc_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/model/api_response_model.dart';

class PCRepository {
  final String baseUrl = ApiConstants.baseApiUrl;

  // Helper method to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all available pre-built PC configurations
  Future<ApiResponse<List<PCModel>>> getAllPCs() async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/pc/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => PCModel.fromJson(item))
              .toList(),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get PC builds');
      }
    } catch (e) {
      throw Exception('Error getting PC builds: $e');
    }
  }

  // Get PC builds for a specific user
  Future<ApiResponse<List<PCModel>>> getPCsByUser(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/pc/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => PCModel.fromJson(item))
              .toList(),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get user PC builds');
      }
    } catch (e) {
      throw Exception('Error getting user PC builds: $e');
    }
  }

  // Build a custom PC
  Future<ApiResponse<PCModel>> buildCustomPC(String name, String userId, Map<String, String> components) async {
    try {
      final headers = await _getAuthHeaders();
      
      final Map<String, dynamic> requestBody = {
        'name': name,
        'userId': userId,
        'components': components,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/pc/custom'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => PCModel.fromJson(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to build custom PC');
      }
    } catch (e) {
      throw Exception('Error building custom PC: $e');
    }
  }

  // Build a gaming PC
  Future<ApiResponse<PCModel>> buildGamingPC(String name, String userId, [Map<String, String>? customComponents]) async {
    try {
      final headers = await _getAuthHeaders();
      
      final Map<String, dynamic> requestBody = {
        'name': name,
        'userId': userId,
        if (customComponents != null) 'customComponents': customComponents,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/pc/gaming'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => PCModel.fromJson(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to build gaming PC');
      }
    } catch (e) {
      throw Exception('Error building gaming PC: $e');
    }
  }

  // Build a workstation PC
  Future<ApiResponse<PCModel>> buildWorkstationPC(String name, String userId, [Map<String, String>? customComponents]) async {
    try {
      final headers = await _getAuthHeaders();
      
      final Map<String, dynamic> requestBody = {
        'name': name,
        'userId': userId,
        if (customComponents != null) 'customComponents': customComponents,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/pc/workstation'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => PCModel.fromJson(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to build workstation PC');
      }
    } catch (e) {
      throw Exception('Error building workstation PC: $e');
    }
  }

  // Update an existing PC
  Future<ApiResponse<PCModel>> updatePC(String pcId, Map<String, String> componentUpdates) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/pc/$pcId'),
        headers: headers,
        body: json.encode(componentUpdates),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => PCModel.fromJson(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update PC');
      }
    } catch (e) {
      throw Exception('Error updating PC: $e');
    }
  }

  // Delete a PC
  Future<ApiResponse<void>> deletePC(String pcId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/pc/$pcId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => null,
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete PC');
      }
    } catch (e) {
      throw Exception('Error deleting PC: $e');
    }
  }
}