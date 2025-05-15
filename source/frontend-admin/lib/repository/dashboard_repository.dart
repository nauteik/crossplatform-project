import 'dart:convert';
import 'package:admin_interface/constants/api_constants.dart';
import 'package:admin_interface/models/dashboard/category_sales_data.dart';
import 'package:admin_interface/models/dashboard/dashboard_data.dart';
import 'package:admin_interface/models/dashboard/time_based_chart_data.dart';
import 'package:http/http.dart' as http;

class DashboardRepository {
  final String _baseUrl = "${ApiConstants.baseApiUrl}/api/dashboard";

  final http.Client httpClient;

  DashboardRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<DashboardData> fetchEnhancedDashboardData() async {
    final url = Uri.parse('$_baseUrl/overview');

    try {
      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Sử dụng fromJson của model DashboardData đã cập nhật
        return DashboardData.fromJson(jsonResponse);
      } else {
        // Xử lý các mã trạng thái lỗi khác
        throw Exception(
            'Failed to load dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc các lỗi khác
      throw Exception('Failed to connect to the server or parse data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchFilteredDashboardData(
      Map<String, String> filterParams) async {
    final uri = Uri.parse('$_baseUrl/statistics')
        .replace(queryParameters: filterParams);
    print(uri);

    try {
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Trả về trực tiếp response JSON từ server
        return jsonResponse;
      } else {
        throw Exception(
            'Failed to load filtered dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch filtered dashboard data: $e');
    }
  }
}
