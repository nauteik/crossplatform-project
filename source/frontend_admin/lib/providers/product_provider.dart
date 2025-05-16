import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_admin/models/product_model.dart';
import 'package:frontend_admin/repository/product_repository.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  
  List<Product> _products = [];
  Product? _currentProduct;
  ProductStatus _status = ProductStatus.initial;
  String _errorMessage = '';
  String _currentCategory = 'all';
  
  // Getters
  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  ProductStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  
  // Lấy tất cả sản phẩm
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.getProducts();
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Lấy chi tiết sản phẩm theo ID
  Future<void> getProductById(String id) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.getProductById(id);
      
      if (response.data != null) {
        _currentProduct = response.data;
        _status = ProductStatus.loaded;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Tìm kiếm sản phẩm
  Future<void> searchProducts(String query) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.searchProducts(query);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Lấy sản phẩm theo thương hiệu
  Future<void> getProductsByBrand(String brandId) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.getProductsByBrand(brandId);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Lấy sản phẩm theo loại
  Future<void> getProductsByType(String typeId) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.getProductsByType(typeId);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  // Tạo sản phẩm mới
  Future<bool> createProduct(Product product, {File? imageFile}) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.createProduct(product, imageFile: imageFile);
      
      if (response.status == 200 && response.data != null) {
        // Thêm sản phẩm mới vào danh sách
        _products.add(response.data!);
        _status = ProductStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Cập nhật sản phẩm
  Future<bool> updateProduct(String id, Product product, {File? imageFile}) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.updateProduct(id, product, imageFile: imageFile);
      
      if (response.status == 200 && response.data != null) {
        // Cập nhật sản phẩm trong danh sách
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = response.data!;
        }
        
        // Nếu đang xem chi tiết sản phẩm này, cập nhật luôn
        if (_currentProduct?.id == id) {
          _currentProduct = response.data;
        }
        
        _status = ProductStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Xóa sản phẩm
  Future<bool> deleteProduct(String id) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.deleteProduct(id);
      
      if (response.status == 200) {
        // Xóa sản phẩm khỏi danh sách
        _products.removeWhere((product) => product.id == id);
        _status = ProductStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}