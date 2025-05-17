import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/brand_model.dart';
import 'package:http/http.dart' as http;

enum BrandStatus { initial, loading, loaded, error }

class BrandProvider with ChangeNotifier {
  List<Brand> _brands = [];
  List<Brand> get brands => _brands;

  BrandStatus _status = BrandStatus.initial;
  BrandStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Lấy danh sách tất cả thương hiệu
  Future<void> fetchBrands() async {
    try {
      _status = BrandStatus.loading;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/brand/brands'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          final List<dynamic> brandsData = responseData['data'];
          _brands = brandsData
              .map((json) => Brand.fromJson(json))
              .toList();

          _status = BrandStatus.loaded;
        } else {
          _errorMessage = responseData['message'] ?? 'Lỗi không xác định';
          _status = BrandStatus.error;
        }
      } else {
        _errorMessage = 'Lỗi kết nối máy chủ: ${response.statusCode}';
        _status = BrandStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _status = BrandStatus.error;
    }

    notifyListeners();
  }

  // Thêm mới thương hiệu
  Future<void> createBrand(Brand brand) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/brand/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(brand.toJson()),
      );

      if (response.statusCode != 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi tạo thương hiệu');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Cập nhật thương hiệu
  Future<void> updateBrand(Brand brand) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/brand/update/${brand.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(brand.toJson()),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi cập nhật thương hiệu');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Xóa thương hiệu
  Future<void> deleteBrand(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/brand/delete/$id'),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi xóa thương hiệu');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}