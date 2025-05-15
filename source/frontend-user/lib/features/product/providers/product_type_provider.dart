import 'package:flutter/material.dart';
import '../../../data/model/product_type_model.dart';
import '../../../data/respository/product_type_repository.dart';
import 'dart:developer' as developer;

enum ProductTypeStatus { initial, loading, loaded, error }

class ProductTypeProvider with ChangeNotifier {
  final ProductTypeRepository _repository = ProductTypeRepository();

  List<ProductTypeModel> _productTypes = [];
  ProductTypeStatus _status = ProductTypeStatus.initial;
  String _errorMessage = '';

  // Getters
  List<ProductTypeModel> get productTypes => _productTypes;
  ProductTypeStatus get status => _status;
  String get errorMessage => _errorMessage;

  // Lấy tất cả loại sản phẩm
  Future<void> fetchProductTypes() async {
    _status = ProductTypeStatus.loading;
    notifyListeners();

    try {
      final response = await _repository.getProductTypes();
     
      if (response.status && response.data != null) {
        _productTypes = response.data!;
        _status = ProductTypeStatus.loaded;
        developer.log("Loaded ${_productTypes.length} product types successfully");
      } else {
        _status = ProductTypeStatus.error;
        _errorMessage = response.message;
        developer.log("Failed to load product types: ${response.message}");
      }
    } catch (e) {
      _status = ProductTypeStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception in fetchProductTypes: $e");
    }

    notifyListeners();
  }
} 