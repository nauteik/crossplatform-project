import 'dart:convert';
import 'package:admin_interface/features/orders_management/models/order_model.dart';
import 'package:http/http.dart' as http;

class OrderController {
  // Base URL for API calls - update to match your actual backend URL
  final String baseUrl = 'http://localhost:8080/api/orders';
  
  // Get all orders
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Server might be down.'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Check for success using "status" instead of "code"
        if ((data['status'] == 200 || data['code'] == 200) && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          return ordersJson.map((json) => Order.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load orders');
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }
  
  // Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$orderId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Check for success using "status" instead of "code"
        if ((data['status'] == 200 || data['code'] == 200) && data['data'] != null) {
          return Order.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load order');
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }
  
  // Process order to next state using State Pattern
  Future<bool> processOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$orderId/process'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      final Map<String, dynamic> data = json.decode(response.body);
      // Check for success using "status" instead of "code"
      return data['status'] == 200 || data['code'] == 200; // Return true if success
    } catch (e) {
      print('Error processing order: $e');
      throw Exception('Failed to process order: $e');
    }
  }
  
  // Cancel order using State Pattern
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$orderId/cancel'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      final Map<String, dynamic> data = json.decode(response.body);
      // Check for success using "status" instead of "code"
      return data['status'] == 200 || data['code'] == 200; // Return true if success
    } catch (e) {
      print('Error cancelling order: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }
  
  // Get orders for a specific user
  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Check for success using "status" instead of "code"
        if ((data['status'] == 200 || data['code'] == 200) && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          return ordersJson.map((json) => Order.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load user orders');
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }
}