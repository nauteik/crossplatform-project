import 'package:flutter/material.dart';
import 'package:frontend_admin/models/api_response_model.dart';
import 'package:frontend_admin/models/product_type_model.dart';
import 'package:frontend_admin/repository/product_type_repository.dart';

enum ProductTypeStatus { initial, loading, loaded, error }

class ProductTypeProvider with ChangeNotifier {
  final ProductTypeRepository _repository = ProductTypeRepository();
  
  List<ProductType> _productTypes = [];
  ProductTypeStatus _status = ProductTypeStatus.initial;
  String _errorMessage = '';
  
  // Getters
  List<ProductType> get productTypes => _productTypes;
  ProductTypeStatus get status => _status;
  String get errorMessage => _errorMessage;
  
  // Lấy tất cả loại sản phẩm
  Future<void> fetchProductTypes() async {
    _status = ProductTypeStatus.loading;
    notifyListeners();
    
    try {
      final ApiResponse<List<ProductType>> response = await _repository.getProductTypes();
      
      if (response.status == 200 && response.data != null) {
        _productTypes = response.data!;
        _status = ProductTypeStatus.loaded;
      } else {
        _status = ProductTypeStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ProductTypeStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Tạo loại sản phẩm mới
  Future<bool> createProductType(ProductType productType) async {
    _status = ProductTypeStatus.loading;
    notifyListeners();
    
    try {
      final ApiResponse<ProductType> response = await _repository.createProductType(productType);
      
      if (response.status == 200 && response.data != null) {
        _productTypes.add(response.data!);
        _status = ProductTypeStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = ProductTypeStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProductTypeStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}