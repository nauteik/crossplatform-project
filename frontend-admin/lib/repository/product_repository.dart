import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_interface/core/config/api_config.dart';
import 'package:admin_interface/models/product_model.dart';
import 'package:admin_interface/models/api_response_model.dart';
import 'dart:io';

class ProductRepository {
  // Lấy tất cả sản phẩm
  Future<ApiResponse<List<Product>>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/products'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> productsJson = responseData['data'];
        final List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
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

  // Tìm kiếm sản phẩm 
  Future<ApiResponse<List<Product>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> productsJson = responseData['data'];
        final List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
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

  // Lấy sản phẩm theo thương hiệu
  Future<ApiResponse<List<Product>>> getProductsByBrand(String brandId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/by-brand/$brandId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> productsJson = responseData['data'];
        final List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
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

  // Lấy sản phẩm theo loại
  Future<ApiResponse<List<Product>>> getProductsByType(String typeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/product/by-type/$typeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final List<dynamic> productsJson = responseData['data'];
        final List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        return ApiResponse<List<Product>>(
          status: responseData['status'],
          message: responseData['message'],
          data: products,
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

  // Tạo sản phẩm mới
  Future<ApiResponse<Product>> createProduct(Product product, {File? imageFile}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/product/create');
      
      // Tạo request với multipart khi có file ảnh
      if (imageFile != null) {
        var request = http.MultipartRequest('POST', url);
        
        // Thêm thông tin sản phẩm dạng JSON
        Map<String, dynamic> productJson = product.toJson();
        request.fields['product'] = json.encode(productJson);
        
        // Thêm file ảnh
        var multipartFile = await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
          filename: imageFile.path.split('/').last
        );
        request.files.add(multipartFile);
        
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
      } else {
        // Nếu không có file ảnh, gửi JSON request bình thường
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(product.toJson()),
        );
        
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
  Future<ApiResponse<Product>> updateProduct(String id, Product product, {File? imageFile}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/product/update/$id');
      
      // Tạo request với multipart khi có file ảnh
      if (imageFile != null) {
        var request = http.MultipartRequest('PUT', url);
        
        // Thêm thông tin sản phẩm dạng JSON
        Map<String, dynamic> productJson = product.toJson();
        request.fields['product'] = json.encode(productJson);
        
        // Thêm file ảnh
        var multipartFile = await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
          filename: imageFile.path.split('/').last
        );
        request.files.add(multipartFile);
        
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
      } else {
        // Nếu không có file ảnh, gửi JSON request bình thường
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(product.toJson()),
        );
        
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