import 'dart:convert';
import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/api_response_model.dart';
import 'package:frontend_admin/models/tag_model.dart';
import 'package:http/http.dart' as http;

class TagRepository {
  // Lấy tất cả tags
  Future<ApiResponse<List<Tag>>> getAllTags() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/tags'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> tagsJson = responseData['data'];
        final List<Tag> tags = tagsJson.map((json) => Tag.fromJson(json)).toList();
        
        return ApiResponse<List<Tag>>(
          status: responseData['status'],
          message: responseData['message'],
          data: tags,
        );
      } else {
        return ApiResponse<List<Tag>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải danh sách tags',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Tag>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Tạo tag mới
  Future<ApiResponse<Tag>> createTag(Tag tag) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/tags/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(tag.toJson()),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 200) {
        return ApiResponse<Tag>(
          status: responseData['status'],
          message: responseData['message'],
          data: Tag.fromJson(responseData['data']),
        );
      } else {
        return ApiResponse<Tag>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tạo tag',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<Tag>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Xóa tag
  Future<ApiResponse<void>> deleteTag(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/tags/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      return ApiResponse<void>(
        status: responseData['status'],
        message: responseData['message'],
        data: null,
      );
    } catch (e) {
      return ApiResponse<void>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Thêm tag cho sản phẩm
  Future<ApiResponse<void>> addTagToProduct(String productId, String tagId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/product/$productId/tags'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'tagId': tagId}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      return ApiResponse<void>(
        status: responseData['status'],
        message: responseData['message'],
        data: null,
      );
    } catch (e) {
      return ApiResponse<void>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Xóa tag khỏi sản phẩm
  Future<ApiResponse<void>> removeTagFromProduct(String productId, String tagId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/product/$productId/tags/$tagId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      return ApiResponse<void>(
        status: responseData['status'],
        message: responseData['message'],
        data: null,
      );
    } catch (e) {
      return ApiResponse<void>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }
} 