import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/tag_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_admin/repository/tag_repository.dart';

enum TagStatus { initial, loading, loaded, error }

class TagProvider with ChangeNotifier {
  final TagRepository _repository = TagRepository();
  
  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  TagStatus _status = TagStatus.initial;
  TagStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Lấy danh sách tất cả tags
  Future<void> fetchTags() async {
    _status = TagStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.getAllTags();
      
      if (response.data != null) {
        _tags = response.data!;
        _status = TagStatus.loaded;
      } else {
        _status = TagStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = TagStatus.error;
      _errorMessage = e.toString();
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
  Future<bool> createTag(Tag tag) async {
    _status = TagStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.createTag(tag);
      
      if (response.data != null) {
        _tags.add(response.data!);
        _status = TagStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TagStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TagStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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
  Future<bool> deleteTag(String id) async {
    _status = TagStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.deleteTag(id);
      
      if (response.status == 200) {
        _tags.removeWhere((tag) => tag.id == id);
        _status = TagStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TagStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TagStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Thêm tag cho sản phẩm
  Future<bool> addTagToProduct(String productId, String tagId) async {
    try {
      final response = await _repository.addTagToProduct(productId, tagId);
      
      if (response.status == 200) {
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  // Xóa tag khỏi sản phẩm
  Future<bool> removeTagFromProduct(String productId, String tagId) async {
    try {
      final response = await _repository.removeTagFromProduct(productId, tagId);
      
      if (response.status == 200) {
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
} 