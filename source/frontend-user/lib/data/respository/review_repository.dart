import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/api_response_model.dart';
import '../../core/constants/api_constants.dart';

class ReviewRepository {
  final String baseUrl = ApiConstants.baseApiUrl;
  final Duration timeout = const Duration(seconds: 15);

  // Lấy tất cả đánh giá của sản phẩm
  Future<ApiResponse<List<dynamic>>> getProductReviews(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reviews/$productId'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => data as List<dynamic>,
        );
      } else {
        throw Exception('Failed to load reviews: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy tổng kết đánh giá của sản phẩm
  Future<ApiResponse<Map<String, dynamic>>> getReviewSummary(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reviews/summary/$productId'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => data as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load review summary: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 