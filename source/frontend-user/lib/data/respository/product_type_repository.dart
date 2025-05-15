import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_type_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_response.dart';
import 'dart:developer' as developer;

class ProductTypeRepository {
  // Lấy danh sách loại sản phẩm
  Future<ApiResponse<List<ProductTypeModel>>> getProductTypes() async {
    try {
      final url = '${ApiConstants.baseUrl}/producttype/types';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        developer.log("Response structure: ${responseData.keys}");
        
        // Kiểm tra cấu trúc response API backend (thường có code, message, data)
        if (responseData.containsKey('data') && responseData.containsKey('status')) {
          int code = responseData['status'];
          String message = responseData['message'] ?? '';
          dynamic data = responseData['data'];
          
          developer.log("API response: code=$code, message=$message");
          
          if (code == 200 && data != null) {
            List<dynamic> productTypesJson = data as List;
            
            // Chuyển đổi dữ liệu từ JSON sang đối tượng ProductTypeModel
            List<ProductTypeModel> productTypes = productTypesJson
                .map((json) {
                  developer.log("ProductType JSON: $json");
                  return ProductTypeModel.fromJson({
                    'id': json['id'],
                    'name': json['name'],
                    'image': json['image'],
                  });
                })
                .toList();
                
            developer.log("Đã chuyển đổi ${productTypes.length} loại sản phẩm");
            for (var type in productTypes) {
              developer.log("Product Type: ${type.name}, Image: ${type.image}");
            }
            
            return ApiResponse<List<ProductTypeModel>>(
              status: true,
              message: message,
              data: productTypes,
            );
          } else {
            developer.log("API returned error code: $code");
            return ApiResponse<List<ProductTypeModel>>(
              status: false,
              message: message,
            );
          }
        } else {
          developer.log("Invalid API response structure: ${responseData.keys}");
          return ApiResponse<List<ProductTypeModel>>(
            status: false,
            message: 'Cấu trúc dữ liệu không đúng',
          );
        }
      } else {
        developer.log("HTTP Error: ${response.statusCode}");
        developer.log("Response body: ${response.body}");
        return ApiResponse<List<ProductTypeModel>>(
          status: false,
          message: 'Lỗi kết nối: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log("Exception caught: $e");
      return ApiResponse<List<ProductTypeModel>>(
        status: false,
        message: 'Có lỗi xảy ra: $e',
      );
    }
  }
} 