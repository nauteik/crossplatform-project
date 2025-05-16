import 'dart:convert';

import 'package:frontend_admin/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class StatisticsRepository {
  final String _baseUrl = "${ApiConstants.baseApiUrl}/api/statistics";

  final http.Client httpClient;

  StatisticsRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> fetchFilteredDashboardData(
      Map<String, String> filterParams) async {
    final uri = Uri.parse(_baseUrl)
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
