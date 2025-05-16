import 'package:flutter/material.dart';
import 'package:frontend_admin/models/api_response_model.dart';
import 'package:frontend_admin/models/brand_model.dart';
import 'package:frontend_admin/repository/brand_repository.dart';

enum BrandStatus { initial, loading, loaded, error }

class BrandProvider with ChangeNotifier {
  final BrandRepository _repository = BrandRepository();
  
  List<Brand> _brands = [];
  BrandStatus _status = BrandStatus.initial;
  String _errorMessage = '';
  
  // Getters
  List<Brand> get brands => _brands;
  BrandStatus get status => _status;
  String get errorMessage => _errorMessage;
  
  // Lấy tất cả thương hiệu
  Future<void> fetchBrands() async {
    _status = BrandStatus.loading;
    notifyListeners();
    
    try {
      final ApiResponse<List<Brand>> response = await _repository.getBrands();
      
      if (response.status == 200 && response.data != null) {
        _brands = response.data!;
        _status = BrandStatus.loaded;
      } else {
        _status = BrandStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = BrandStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Tạo thương hiệu mới
  Future<bool> createBrand(Brand brand) async {
    _status = BrandStatus.loading;
    notifyListeners();
    
    try {
      final ApiResponse<Brand> response = await _repository.createBrand(brand);
      
      if (response.status == 200 && response.data != null) {
        _brands.add(response.data!);
        _status = BrandStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = BrandStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = BrandStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}