import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../../data/model/product_model.dart';
import '../../../../data/model/api_response_model.dart';
import '../../../../core/constants/api_constants.dart';

class ProductRepository {
  final String baseUrl = ApiConstants.baseApiUrl;
  final Duration timeout = const Duration(seconds: 15);

  // Lấy tất cả sản phẩm
  Future<ApiResponse<List<ProductModel>>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/product/products')
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        return ApiResponse.fromJson(
          responseData,
          (data) => (data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList(),
        );
      } else {
        throw Exception('Failed to load products: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Kết nối đến server quá thời gian chờ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy sản phẩm theo phân trang
  Future<ApiResponse<Map<String, dynamic>>> getPagedProducts(int page, int size) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/product/products/paged?page=$page&size=$size'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        return ApiResponse.fromJson(
          responseData,
          (data) => data as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load paged products: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Kết nối đến server quá thời gian chờ. Vui lòng thử lại sau.');
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
  Future<ApiResponse<List<ProductModel>>> getProductsByBrand(
      String brandId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/product/by-brand/$brandId'));

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
  Future<ApiResponse<List<ProductModel>>> getProductsByType(
      String typeId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/product/by-type/$typeId'));

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

  Future<ApiResponse<List<String>>> getProductImages(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/images/product/$productId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => List<String>.from(data),
        );
      } else {
        throw Exception('Failed to load product images');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ApiResponse<String>> getPrimaryImage(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/images/product/$productId/primary'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse.fromJson(
          responseData,
          (data) => data as String,
        );
      } else {
        throw Exception('Failed to load primary image');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
