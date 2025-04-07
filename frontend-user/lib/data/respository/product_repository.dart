import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../data/model/product_model.dart';
import '../../../../data/model/api_response_model.dart';
import '../../../../core/constants/api_constants.dart';

class ProductRepository {
 
  final String baseUrl = ApiConstants.baseApiUrl;

  // Lấy tất cả sản phẩm
  Future<ApiResponse<List<ProductModel>>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/products'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList(),
        );
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy sản phẩm theo ID
  Future<ApiResponse<ProductModel>> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => ProductModel.fromJson(data),
        );
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tìm kiếm sản phẩm
  Future<ApiResponse<List<ProductModel>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/product/search?query=$query'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList(),
        );
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy sản phẩm theo thương hiệu
  Future<ApiResponse<List<ProductModel>>> getProductsByBrand(String brandId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/by-brand/$brandId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList(),
        );
      } else {
        throw Exception('Failed to load products by brand');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy sản phẩm theo loại
  Future<ApiResponse<List<ProductModel>>> getProductsByType(String typeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/by-type/$typeId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList(),
        );
      } else {
        throw Exception('Failed to load products by type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 