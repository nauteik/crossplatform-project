import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_interface/core/config/api_config.dart';
import 'package:admin_interface/models/product_type_model.dart';
import 'package:admin_interface/models/api_response_model.dart';

class ProductTypeRepository {
  Future<ApiResponse<List<ProductType>>> getProductTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/types'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> typesJson = responseData['data'];
        final List<ProductType> types = typesJson.map((json) => ProductType.fromJson(json)).toList();
        
        return ApiResponse<List<ProductType>>(
          status: responseData['status'],
          message: responseData['message'],
          data: types,
        );
      } else {
        return ApiResponse<List<ProductType>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải danh sách loại sản phẩm',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<ProductType>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse<ProductType>> createProductType(ProductType productType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(productType.toJson()),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 200) {
        final ProductType newType = ProductType.fromJson(responseData['data']);
        
        return ApiResponse<ProductType>(
          status: responseData['status'],
          message: responseData['message'],
          data: newType,
        );
      } else {
        return ApiResponse<ProductType>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tạo loại sản phẩm mới',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<ProductType>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }
}