import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/config/api_config.dart';
import 'package:frontend_admin/models/product_type_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';

enum ProductTypeStatus { initial, loading, loaded, error }

class ProductTypeProvider with ChangeNotifier {
  List<ProductType> _productTypes = [];
  List<ProductType> get productTypes => _productTypes;

  ProductTypeStatus _status = ProductTypeStatus.initial;
  ProductTypeStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Lấy danh sách tất cả danh mục sản phẩm
  Future<void> fetchProductTypes() async {
    try {
      _status = ProductTypeStatus.loading;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/types'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          final List<dynamic> productsData = responseData['data'];
          _productTypes = productsData
              .map((json) => ProductType.fromJson(json))
              .toList();

          _status = ProductTypeStatus.loaded;
        } else {
          _errorMessage = responseData['message'] ?? 'Lỗi không xác định';
          _status = ProductTypeStatus.error;
        }
      } else {
        _errorMessage = 'Lỗi kết nối máy chủ: ${response.statusCode}';
        _status = ProductTypeStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _status = ProductTypeStatus.error;
    }

    notifyListeners();
  }

  // Thêm mới danh mục sản phẩm (chỉ dữ liệu, không có ảnh)
  Future<void> createProductType(ProductType productType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(productType.toJson()),
      );

      if (response.statusCode != 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi tạo danh mục sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Thêm mới danh mục sản phẩm với hình ảnh
  Future<void> createProductTypeWithImage(String name, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/create-with-image'),
      );

      // Thêm tên danh mục
      request.fields['name'] = name;

      // Thêm file hình ảnh nếu có
      if (imageFile != null) {
        String fileName = imageFile.name;
        String extension = fileName.split('.').last.toLowerCase();
        
        // Đọc nội dung file dưới dạng bytes
        final bytes = await imageFile.readAsBytes();
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: fileName,
            contentType: MediaType('image', extension),
          ),
        );
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      
      if (response.statusCode != 201) {
        final Map<String, dynamic> responseData = json.decode(responseString);
        throw Exception(responseData['message'] ?? 'Lỗi khi tạo danh mục sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Cập nhật danh mục sản phẩm (chỉ dữ liệu, không có ảnh)
  Future<void> updateProductType(ProductType productType) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/update/${productType.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(productType.toJson()),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi cập nhật danh mục sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Cập nhật danh mục sản phẩm với hình ảnh
  Future<void> updateProductTypeWithImage(String id, String name, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/update-with-image/$id'),
      );

      // Thêm tên danh mục
      request.fields['name'] = name;

      // Thêm file hình ảnh nếu có
      if (imageFile != null) {
        String fileName = imageFile.name;
        String extension = fileName.split('.').last.toLowerCase();
        
        // Đọc nội dung file dưới dạng bytes
        final bytes = await imageFile.readAsBytes();
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: fileName,
            contentType: MediaType('image', extension),
          ),
        );
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      
      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(responseString);
        throw Exception(responseData['message'] ?? 'Lỗi khi cập nhật danh mục sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Cập nhật danh mục sản phẩm với đường dẫn hình ảnh có sẵn
  Future<void> updateProductTypeWithImageUrl(String id, String name, String imageUrl) async {
    try {
      // Tạo ProductType từ thông tin cung cấp
      final productType = ProductType(
        id: id,
        name: name,
        image: imageUrl
      );
      
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/update/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(productType.toJson()),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi cập nhật danh mục sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Xóa danh mục sản phẩm
  Future<void> deleteProductType(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/producttype/delete/$id'),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi khi xóa danh mục sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}