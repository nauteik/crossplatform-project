import 'package:flutter/material.dart';
import '../../../../core/models/address_model.dart';
import '../../../../core/services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();
  
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Lấy địa chỉ mặc định nếu có
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
  
  // Lấy danh sách địa chỉ của người dùng
  Future<void> fetchUserAddresses(String userId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _addresses = await _addressService.getUserAddresses(userId, token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Thêm địa chỉ mới
  Future<bool> addAddress(String userId, AddressModel address, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _addressService.addAddress(userId, address, token);
      if (result) {
        await fetchUserAddresses(userId, token);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Cập nhật địa chỉ
  Future<bool> updateAddress(String userId, String addressId, AddressModel address, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _addressService.updateAddress(userId, addressId, address, token);
      if (result) {
        await fetchUserAddresses(userId, token);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Xóa địa chỉ
  Future<bool> deleteAddress(String userId, String addressId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _addressService.deleteAddress(userId, addressId, token);
      if (result) {
        await fetchUserAddresses(userId, token);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Đặt địa chỉ mặc định
  Future<bool> setDefaultAddress(String userId, String addressId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _addressService.setDefaultAddress(userId, addressId, token);
      if (result) {
        await fetchUserAddresses(userId, token);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
} 