import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../model/order_model.dart';
import '../model/api_response_model.dart';
import '../../core/constants/api_constants.dart';

class OrderRepository {
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

  // Create a new order
  Future<ApiResponse<OrderModel>> createOrder({
    required String userId,
    required String shippingAddress,
    required String paymentMethod,
    required List<String> selectedItemIds, // Add this parameter to pass selected item IDs
  }) async {
    print('--- Creating Order ---');
    print('User ID: $userId');
    print('Shipping Address: $shippingAddress');
    print('Payment Method: $paymentMethod');
    print('Selected Item IDs: $selectedItemIds'); // Log selected item IDs
    
    final requestBody = json.encode({
      'userId': userId,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'selectedItemIds': selectedItemIds, // Include selected item IDs in the request
    });
    print('Request Body: $requestBody');

    try {
      // Get authorization headers using the helper method
      final headers = await _getAuthHeaders();
      print('Request Headers: $headers'); // Log headers
      
      // Make the HTTP POST request with the authorization headers
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/create'),
        headers: headers,
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}'); // Log status code
      print('Response Body Raw: ${response.body}'); // Log raw response body
      if (response.statusCode == 201) {
        // Decode only if body is not empty
        if (response.body.isEmpty) {
          throw Exception('Backend returned empty response body with status 201');
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response Body Decoded (Success): $responseData');
        return ApiResponse.fromJson(
          responseData,
          (data) => OrderModel.fromJson(data),
        );
      } else {
        // Decode only if body is not empty
        if (response.body.isEmpty) {
           throw Exception('Failed to create order (Status code: ${response.statusCode}, Empty Response Body)');
        }
        print('Attempting to decode error response...');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('Response Body Decoded (Error): $errorData');
        throw Exception(errorData['message'] ?? 'Failed to create order (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error caught in createOrder: $e');
      // Check if the error is specifically a FormatException from json.decode
      if (e is FormatException) {
         // Try to include the raw response in the error message if possible
         final rawResponse = e.source is String ? e.source as String : '(Could not get raw response)';
         throw Exception('Error creating order: Failed to parse backend response. Raw response: $rawResponse');
      }
      throw Exception('Error creating order: $e'); // Re-throw original or wrapped exception
    }
  }

  // Process payment for an order
  Future<ApiResponse<OrderModel>> processPayment({
    required String orderId,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/$orderId/pay'),
        headers: headers,
        body: json.encode(paymentDetails),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => OrderModel.fromJson(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to process payment');
      }
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }

  // Get order by ID
  Future<ApiResponse<OrderModel>> getOrderById(String orderId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => OrderModel.fromJson(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get order');
      }
    } catch (e) {
      throw Exception('Error getting order: $e');
    }
  }

  // Get orders by user ID
  Future<ApiResponse<List<OrderModel>>> getOrdersByUser(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => OrderModel.fromJson(item))
              .toList(),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get orders');
      }
    } catch (e) {
      throw Exception('Error getting orders: $e');
    }
  }

  // Get supported payment methods
  Future<ApiResponse<List<String>>> getSupportedPaymentMethods() async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/payment-methods'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => List<String>.from(data),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get payment methods');
      }
    } catch (e) {
      throw Exception('Error getting payment methods: $e');
    }
  }
}