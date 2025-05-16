import 'dart:convert';
import 'package:admin_interface/constants/api_constants.dart';
import 'package:admin_interface/models/dashboard/dashboard_data.dart';
import 'package:http/http.dart' as http;

class OverviewRepository {
  final String _baseUrl = "${ApiConstants.baseApiUrl}/api/overview";

  final http.Client httpClient;

  OverviewRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> fetchOverviewData() async {
    final uri = Uri.parse(_baseUrl);

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
