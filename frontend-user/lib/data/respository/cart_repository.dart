import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../data/model/api_response_model.dart';
import '../../../../core/constants/api_constants.dart';

class CartRepository {
  final String baseUrl = ApiConstants.baseApiUrl;

  // Thêm sản phẩm vào giỏ hàng
  Future<ApiResponse<dynamic>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cart/$userId/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': productId,
          'name': name,
          'price': price,
          'imageUrl': imageUrl,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return ApiResponse(
          status: 1,
          message: 'Thêm vào giỏ hàng thành công',
          data: responseData,
        );
      } else {
        return ApiResponse(
          status: 0,
          message: 'Thêm vào giỏ hàng thất bại',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 0,
        message: 'Lỗi khi thêm vào giỏ hàng: $e',
        data: null,
      );
    }
  }

  // Lấy giỏ hàng theo userId
  Future<ApiResponse<dynamic>> getCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cart/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse(
          status: 1,
          message: 'Lấy giỏ hàng thành công',
          data: responseData,
        );
      } else {
        return ApiResponse(
          status: 0,
          message: 'Lấy giỏ hàng thất bại',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 0,
        message: 'Lỗi khi lấy giỏ hàng: $e',
        data: null,
      );
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<ApiResponse<dynamic>> removeFromCart(
    String userId,
    String productId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/$userId/items/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse(
          status: 1,
          message: 'Xóa sản phẩm khỏi giỏ hàng thành công',
          data: responseData,
        );
      } else {
        return ApiResponse(
          status: 0,
          message: 'Xóa sản phẩm khỏi giỏ hàng thất bại',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 0,
        message: 'Lỗi khi xóa sản phẩm khỏi giỏ hàng: $e',
        data: null,
      );
    }
  }

  // Xóa nhiều sản phẩm khỏi giỏ hàng (sau khi thanh toán)
  Future<ApiResponse<dynamic>> removeMultipleFromCart(
    String userId,
    List<String> productIds,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/$userId/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productIds': productIds}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse(
          status: 1,
          message: 'Xóa các sản phẩm khỏi giỏ hàng thành công',
          data: responseData,
        );
      } else {
        return ApiResponse(
          status: 0,
          message: 'Xóa các sản phẩm khỏi giỏ hàng thất bại',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 0,
        message: 'Lỗi khi xóa các sản phẩm khỏi giỏ hàng: $e',
        data: null,
      );
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<ApiResponse<dynamic>> clearCart(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        return ApiResponse(
          status: 1,
          message: 'Xóa giỏ hàng thành công',
          data: null,
        );
      } else {
        return ApiResponse(
          status: 0,
          message: 'Xóa giỏ hàng thất bại',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 0,
        message: 'Lỗi khi xóa giỏ hàng: $e',
        data: null,
      );
    }
  }
}
