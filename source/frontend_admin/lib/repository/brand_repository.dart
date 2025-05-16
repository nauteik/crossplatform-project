import 'dart:convert';

import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/api_response_model.dart';
import 'package:frontend_admin/models/brand_model.dart';
import 'package:http/http.dart' as http;

class BrandRepository {
  Future<ApiResponse<List<Brand>>> getBrands() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/brand/brands'),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> brandsJson = responseData['data'];
        final List<Brand> brands =
            brandsJson.map((json) => Brand.fromJson(json)).toList();

        return ApiResponse<List<Brand>>(
          status: responseData['status'],
          message: responseData['message'],
          data: brands,
        );
      } else {
        return ApiResponse<List<Brand>>(
          status: responseData['status'],
          message:
              responseData['message'] ?? 'Không thể tải danh sách thương hiệu',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Brand>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse<Brand>> createBrand(Brand brand) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/brand/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(brand.toJson()),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 200) {
        final Brand newBrand = Brand.fromJson(responseData['data']);

        return ApiResponse<Brand>(
          status: responseData['status'],
          message: responseData['message'],
          data: newBrand,
        );
      } else {
        return ApiResponse<Brand>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tạo thương hiệu mới',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<Brand>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }
}
