import 'dart:convert';

import 'package:frontend_admin/features/orders_management/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_admin/constants/api_constants.dart';

enum DateFilter {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  custom
}

class OrderController {
  // Base URL for API calls - update to match your actual backend URL
  final String baseUrl = ApiConstants.baseUrl + '/orders';
  
  // Get all orders with pagination and date filtering
  Future<Map<String, dynamic>> getAllOrders({
    int page = 0,
    int size = 20,
    String? status,
    DateFilter dateFilter = DateFilter.all,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };
      
      // Add status filter if provided
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }
      
      // Add date filter parameters
      _addDateFilterParams(queryParams, dateFilter, startDate, endDate);
      
      // Build the URL with query parameters
      Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Server might be down.'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Check for success using "status" instead of "code"
        if ((data['status'] == 200 || data['code'] == 200) && data['data'] != null) {
          // Handle both paginated and non-paginated responses
          if (data['data'] is Map<String, dynamic>) {
            // Paginated response (new format)
            final Map<String, dynamic> pageData = data['data'];
            if (pageData.containsKey('orders') && pageData['orders'] is List) {
              final List<dynamic> ordersJson = pageData['orders'] as List<dynamic>;
              List<Order> orders = ordersJson.map((json) => Order.fromJson(json)).toList();
              
              // Sắp xếp đơn hàng theo thời gian tạo, mới nhất trước
              orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              
              return {
                'orders': orders,
                'currentPage': pageData['currentPage'] ?? page,
                'totalPages': pageData['totalPages'] ?? 1,
                'totalItems': pageData['totalItems'] ?? orders.length,
              };
            } else {
              throw Exception('Invalid response format: missing "orders" field in paginated data');
            }
          } else if (data['data'] is List) {
            // Non-paginated response (old format)
            final List<dynamic> ordersJson = data['data'] as List<dynamic>;
            List<Order> orders = ordersJson.map((json) => Order.fromJson(json)).toList();
            
            // Sắp xếp đơn hàng theo thời gian tạo, mới nhất trước
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            // Return with default pagination values
            return {
              'orders': orders,
              'currentPage': page,
              'totalPages': 1,
              'totalItems': orders.length,
            };
          } else {
            throw Exception('Unexpected data format in response');
          }
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
  
  // Helper method to add date filter parameters to the query
  void _addDateFilterParams(
    Map<String, String> queryParams,
    DateFilter dateFilter,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final now = DateTime.now();
    
    switch (dateFilter) {
      case DateFilter.today:
        // Lấy từ 00:00:00 đến 23:59:59 của ngày hôm nay
        final today = DateTime(now.year, now.month, now.day);
        final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        queryParams['startDate'] = today.toIso8601String();
        queryParams['endDate'] = todayEnd.toIso8601String();
        break;
        
      case DateFilter.yesterday:
        // Lấy từ 00:00:00 đến 23:59:59 của ngày hôm qua
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final yesterdayEnd = DateTime(now.year, now.month, now.day - 1, 23, 59, 59, 999);
        queryParams['startDate'] = yesterday.toIso8601String();
        queryParams['endDate'] = yesterdayEnd.toIso8601String();
        break;
        
      case DateFilter.thisWeek:
        // Đầu tuần là ngày Thứ Hai (weekday = 1)
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
        // Kết thúc tuần hiện tại, 23:59:59
        final endOfWeek = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        queryParams['startDate'] = startOfWeek.toIso8601String();
        queryParams['endDate'] = endOfWeek.toIso8601String();
        break;
        
      case DateFilter.thisMonth:
        // Ngày đầu tiên của tháng hiện tại
        final startOfMonth = DateTime(now.year, now.month, 1);
        // Ngày cuối cùng của tháng hiện tại, kết thúc vào 23:59:59
        final endOfMonth = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        queryParams['startDate'] = startOfMonth.toIso8601String();
        queryParams['endDate'] = endOfMonth.toIso8601String();
        break;
        
      case DateFilter.lastMonth:
        // Ngày đầu tiên của tháng trước
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        // Ngày cuối cùng của tháng trước, kết thúc vào 23:59:59
        // Sử dụng ngày 0 của tháng hiện tại để lấy ngày cuối cùng của tháng trước
        final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        queryParams['startDate'] = startOfLastMonth.toIso8601String();
        queryParams['endDate'] = endOfLastMonth.toIso8601String();
        break;
        
      case DateFilter.custom:
        // Với custom filter, đảm bảo cả startDate và endDate đều được thiết lập
        if (startDate != null) {
          // Đặt giờ bắt đầu là 00:00:00
          final startDateTime = DateTime(startDate.year, startDate.month, startDate.day);
          queryParams['startDate'] = startDateTime.toIso8601String();
        }
        if (endDate != null) {
          // Đặt giờ kết thúc là 23:59:59
          final endDateTime = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
          queryParams['endDate'] = endDateTime.toIso8601String();
        }
        break;
        
      case DateFilter.all:
      default:
        // Không áp dụng bất kỳ filter nào
        break;
    }
    
    // Log để debug
    if (queryParams.containsKey('startDate') && queryParams.containsKey('endDate')) {
      print('Date filter: ${dateFilter.toString()}');
      print('Start date: ${queryParams['startDate']}');
      print('End date: ${queryParams['endDate']}');
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