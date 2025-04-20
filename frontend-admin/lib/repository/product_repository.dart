import 'dart:convert';
import 'package:admin_interface/constants/api_constants.dart';
import 'package:admin_interface/models/api_response_model.dart';
import 'package:admin_interface/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
 
  final String baseUrl = ApiConstants.baseApiUrl;

  // Lấy tất cả sản phẩm
  Future<ApiResponse<List<Product>>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/products'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => Product.fromJson(item))
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
  Future<ApiResponse<Product>> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => Product.fromJson(data),
        );
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tìm kiếm sản phẩm
  Future<ApiResponse<List<Product>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/product/search?query=$query'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => Product.fromJson(item))
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
  Future<ApiResponse<List<Product>>> getProductsByBrand(String brandId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/by-brand/$brandId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => Product.fromJson(item))
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
  Future<ApiResponse<List<Product>>> getProductsByType(String typeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/product/by-type/$typeId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => Product.fromJson(item))
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