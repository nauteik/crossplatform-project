import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/address_model.dart';

class AddressService {
  final String baseUrl = ApiConstants.baseApiUrl;

  // Lấy danh sách địa chỉ của người dùng
  Future<List<AddressModel>> getUserAddresses(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/address/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        final List<dynamic> addressesData = responseData['data'];
        return addressesData
            .map((address) => AddressModel.fromJson(address))
            .toList();
      }
      return [];
    } else {
      throw Exception('Không thể lấy địa chỉ: ${response.body}');
    }
  }

  // Thêm địa chỉ mới
  Future<bool> addAddress(
      String userId, AddressModel address, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/address/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(address.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Không thể thêm địa chỉ: ${response.body}');
    }
  }

  // Cập nhật địa chỉ
  Future<bool> updateAddress(
      String userId, String addressId, AddressModel address, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/address/$userId/$addressId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(address.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Không thể cập nhật địa chỉ: ${response.body}');
    }
  }

  // Xóa địa chỉ
  Future<bool> deleteAddress(
      String userId, String addressId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/address/$userId/$addressId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Không thể xóa địa chỉ: ${response.body}');
    }
  }

  // Đặt địa chỉ mặc định
  Future<bool> setDefaultAddress(
      String userId, String addressId, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/address/$userId/$addressId/default'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Không thể đặt địa chỉ mặc định: ${response.body}');
    }
  }
} 