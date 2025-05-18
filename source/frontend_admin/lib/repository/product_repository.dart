import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/api_response_model.dart';
import 'package:frontend_admin/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductRepository {
  // Lấy tất cả sản phẩm (thêm tham số phân trang)
  Future<ApiResponse<List<Product>>> getProducts({int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/products/paged?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        // Xử lý nhiều kiểu phản hồi có thể có
        final data = responseData['data'];
        List<Product> products = [];
        Map<String, dynamic> meta = {
          'currentPage': page,
          'totalItems': 0,
          'totalPages': 1,
        };
        
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          // Trường hợp data là Map và có trường products
          final productsJson = data['products'];
          if (productsJson is List) {
            products = productsJson.map((json) => Product.fromJson(json)).toList();
          }
          // Lưu thông tin phân trang nếu có
          if (data.containsKey('currentPage')) meta['currentPage'] = data['currentPage'];
          if (data.containsKey('totalItems')) meta['totalItems'] = data['totalItems'];
          if (data.containsKey('totalPages')) meta['totalPages'] = data['totalPages'];
        } else if (data is List) {
          // Trường hợp data trực tiếp là List các sản phẩm
          products = data.map((json) => Product.fromJson(json)).toList();
          meta = {
            'currentPage': page,
            'totalItems': products.length,
            'totalPages': 1,
          };
        }
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
          meta: meta,
        );
      } else {
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải danh sách sản phẩm',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Lấy sản phẩm theo ID
  Future<ApiResponse<Product>> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final Product product = Product.fromJson(responseData['data']);
        
        return ApiResponse<Product>(
          status: responseData['status'],
          message: responseData['message'],
          data: product,
        );
      } else {
        return ApiResponse<Product>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải thông tin sản phẩm',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<Product>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Tìm kiếm sản phẩm (thêm tham số phân trang)
  Future<ApiResponse<List<Product>>> searchProducts(String query, {int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/search?query=$query&page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        // Xử lý nhiều kiểu phản hồi có thể có
        final data = responseData['data'];
        List<Product> products = [];
        Map<String, dynamic> meta = {
          'currentPage': page,
          'totalItems': 0,
          'totalPages': 1,
        };
        
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          // Trường hợp data là Map và có trường products
          final productsJson = data['products'];
          if (productsJson is List) {
            products = productsJson.map((json) => Product.fromJson(json)).toList();
          }
          // Lưu thông tin phân trang nếu có
          if (data.containsKey('currentPage')) meta['currentPage'] = data['currentPage'];
          if (data.containsKey('totalItems')) meta['totalItems'] = data['totalItems'];
          if (data.containsKey('totalPages')) meta['totalPages'] = data['totalPages'];
        } else if (data is List) {
          // Trường hợp data trực tiếp là List các sản phẩm
          products = data.map((json) => Product.fromJson(json)).toList();
          meta = {
            'currentPage': page,
            'totalItems': products.length,
            'totalPages': 1,
          };
        }
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
          meta: meta,
        );
      } else {
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tìm sản phẩm',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Lấy sản phẩm theo thương hiệu (thêm tham số phân trang)
  Future<ApiResponse<List<Product>>> getProductsByBrand(String brandId, {int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/by-brand/$brandId?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        // Xử lý nhiều kiểu phản hồi có thể có
        final data = responseData['data'];
        List<Product> products = [];
        Map<String, dynamic> meta = {
          'currentPage': page,
          'totalItems': 0,
          'totalPages': 1,
        };
        
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          // Trường hợp data là Map và có trường products
          final productsJson = data['products'];
          if (productsJson is List) {
            products = productsJson.map((json) => Product.fromJson(json)).toList();
          }
          // Lưu thông tin phân trang nếu có
          if (data.containsKey('currentPage')) meta['currentPage'] = data['currentPage'];
          if (data.containsKey('totalItems')) meta['totalItems'] = data['totalItems'];
          if (data.containsKey('totalPages')) meta['totalPages'] = data['totalPages'];
        } else if (data is List) {
          // Trường hợp data trực tiếp là List các sản phẩm
          products = data.map((json) => Product.fromJson(json)).toList();
          meta = {
            'currentPage': page,
            'totalItems': products.length,
            'totalPages': 1,
          };
        }
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
          meta: meta,
        );
      } else {
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải sản phẩm theo thương hiệu',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Lấy sản phẩm theo loại (thêm tham số phân trang)
  Future<ApiResponse<List<Product>>> getProductsByType(String typeId, {int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/by-type/$typeId?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        // Xử lý nhiều kiểu phản hồi có thể có
        final data = responseData['data'];
        List<Product> products = [];
        Map<String, dynamic> meta = {
          'currentPage': page,
          'totalItems': 0,
          'totalPages': 1,
        };
        
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          // Trường hợp data là Map và có trường products
          final productsJson = data['products'];
          if (productsJson is List) {
            products = productsJson.map((json) => Product.fromJson(json)).toList();
          }
          // Lưu thông tin phân trang nếu có
          if (data.containsKey('currentPage')) meta['currentPage'] = data['currentPage'];
          if (data.containsKey('totalItems')) meta['totalItems'] = data['totalItems'];
          if (data.containsKey('totalPages')) meta['totalPages'] = data['totalPages'];
        } else if (data is List) {
          // Trường hợp data trực tiếp là List các sản phẩm
          products = data.map((json) => Product.fromJson(json)).toList();
          meta = {
            'currentPage': page,
            'totalItems': products.length,
            'totalPages': 1,
          };
        }
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
          meta: meta,
        );
      } else {
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải sản phẩm theo loại',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }
  
  // Lấy sản phẩm theo tag (thêm chức năng mới)
  Future<ApiResponse<List<Product>>> getProductsByTag(String tagId, {int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/by-tag/$tagId?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        // Xử lý nhiều kiểu phản hồi có thể có
        final data = responseData['data'];
        List<Product> products = [];
        Map<String, dynamic> meta = {
          'currentPage': page,
          'totalItems': 0,
          'totalPages': 1,
        };
        
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          // Trường hợp data là Map và có trường products
          final productsJson = data['products'];
          if (productsJson is List) {
            products = productsJson.map((json) => Product.fromJson(json)).toList();
          }
          // Lưu thông tin phân trang nếu có
          if (data.containsKey('currentPage')) meta['currentPage'] = data['currentPage'];
          if (data.containsKey('totalItems')) meta['totalItems'] = data['totalItems'];
          if (data.containsKey('totalPages')) meta['totalPages'] = data['totalPages'];
        } else if (data is List) {
          // Trường hợp data trực tiếp là List các sản phẩm
          products = data.map((json) => Product.fromJson(json)).toList();
          meta = {
            'currentPage': page,
            'totalItems': products.length,
            'totalPages': 1,
          };
        }
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
          meta: meta,
        );
      } else {
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'] ?? 'Không thể tải sản phẩm theo tag',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Tạo sản phẩm mới
  Future<ApiResponse<Product>> createProduct(Product product, {XFile? imageFile}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/product/create-with-image');
      
      // Luôn tạo MultipartRequest để đảm bảo Content-Type là multipart/form-data
      var request = http.MultipartRequest('POST', url);
      
      // Thêm thông tin sản phẩm dạng JSON
      Map<String, dynamic> productJson = product.toJson();
      productJson.remove('id'); // Bỏ id để backend tạo tự động
      request.fields['product'] = json.encode(productJson);
      
      // Thêm file ảnh nếu có
      if (imageFile != null) {
        if (kIsWeb) {
          Uint8List imageBytes = await imageFile.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageFile.name,
          );
          request.files.add(multipartFile);
        } else {
          var multipartFile = await http.MultipartFile.fromPath(
            'image', 
            imageFile.path,
            filename: imageFile.path.split('/').last
          );
          request.files.add(multipartFile);
        }
      }
      
      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 && responseData['status'] == 200) {
        return ApiResponse<Product>(
          status: responseData['status'],
          message: responseData['message'],
          data: Product.fromJson(responseData['data']),
        );
      } else {
        return ApiResponse<Product>(
          status: responseData['status'] ?? response.statusCode,
          message: responseData['message'] ?? 'Lỗi khi tạo sản phẩm',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<Product>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Cập nhật sản phẩm
  Future<ApiResponse<Product>> updateProduct(String id, Product product, {XFile? imageFile}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/product/update-with-image/$id');
      
      // Luôn tạo MultipartRequest để đảm bảo Content-Type là multipart/form-data
      var request = http.MultipartRequest('PUT', url);
      
      // Thêm thông tin sản phẩm dạng JSON
      Map<String, dynamic> productJson = product.toJson();
      request.fields['product'] = json.encode(productJson);
      
      // Thêm file ảnh nếu có
      if (imageFile != null) {
        if (kIsWeb) {
          Uint8List imageBytes = await imageFile.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageFile.name,
          );
          request.files.add(multipartFile);
        } else {
          var multipartFile = await http.MultipartFile.fromPath(
            'image', 
            imageFile.path,
            filename: imageFile.path.split('/').last
          );
          request.files.add(multipartFile);
        }
      }
      
      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['status'] == 200) {
        return ApiResponse<Product>(
          status: responseData['status'],
          message: responseData['message'],
          data: Product.fromJson(responseData['data']),
        );
      } else {
        return ApiResponse<Product>(
          status: responseData['status'] ?? response.statusCode,
          message: responseData['message'] ?? 'Lỗi khi cập nhật sản phẩm',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<Product>(
        status: 500,
        message: 'Lỗi kết nối: $e',
        data: null,
      );
    }
  }

  // Xóa sản phẩm
  Future<ApiResponse<void>> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/product/delete/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final responseData = json.decode(response.body);
      
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