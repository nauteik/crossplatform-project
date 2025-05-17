import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/tag_model.dart';
import 'package:http/http.dart' as http;

enum TagStatus { initial, loading, loaded, error }

class TagProvider with ChangeNotifier {
  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  TagStatus _status = TagStatus.initial;
  TagStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Lấy danh sách tất cả tags
  Future<void> fetchTags() async {
    try {
      _status = TagStatus.loading;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/tags'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          final List<dynamic> tagsData = responseData['data'];
          _tags = tagsData
              .map((json) => Tag.fromJson(json))
              .toList();

          _status = TagStatus.loaded;
        } else {
          _errorMessage = responseData['message'] ?? 'Lỗi không xác định';
          _status = TagStatus.error;
        }
      } else {
        _errorMessage = 'Lỗi kết nối máy chủ: ${response.statusCode}';
        _status = TagStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _status = TagStatus.error;
    }

    notifyListeners();
  }

  // Lấy tags đang hoạt động
  Future<void> fetchActiveTags() async {
    try {
      _status = TagStatus.loading;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/tags/active'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          final List<dynamic> tagsData = responseData['data'];
          _tags = tagsData
              .map((json) => Tag.fromJson(json))
              .toList();

          _status = TagStatus.loaded;
        } else {
          _errorMessage = responseData['message'] ?? 'Lỗi không xác định';
          _status = TagStatus.error;
        }
      } else {
        _errorMessage = 'Lỗi kết nối máy chủ: ${response.statusCode}';
        _status = TagStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _status = TagStatus.error;
    }

    notifyListeners();
  }

  // Thêm mới tag
  Future<void> createTag(Tag tag) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/tags'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(tag.toJson()),
      );

      if (response.statusCode != 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi tạo tag');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Cập nhật tag
  Future<void> updateTag(Tag tag) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/tags/${tag.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(tag.toJson()),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi cập nhật tag');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Xóa tag
  Future<void> deleteTag(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/tags/$id'),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi xóa tag');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
} 