import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_admin/models/product_model.dart';
import 'package:frontend_admin/repository/product_repository.dart';
import 'package:image_picker/image_picker.dart';

enum ProductStatus { initial, loading, loaded, error }
enum ProductSortField { createdAt, price, name, quantity, soldCount }
enum SortDirection { asc, desc }

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  
  List<Product> _products = [];
  Product? _currentProduct;
  ProductStatus _status = ProductStatus.initial;
  String _errorMessage = '';
  String _currentCategory = 'all';
  String? _currentBrandId;
  String? _currentTypeId;
  String? _currentTagId;
  String _searchQuery = '';
  
  // Phân trang
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalItems = 0;
  int _pageSize = 20;
  
  // Sắp xếp
  ProductSortField _sortField = ProductSortField.createdAt;
  SortDirection _sortDirection = SortDirection.desc;
  
  // Getters
  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  ProductStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  String? get currentBrandId => _currentBrandId;
  String? get currentTypeId => _currentTypeId;
  String? get currentTagId => _currentTagId;
  String get searchQuery => _searchQuery;
  
  // Getters phân trang
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get pageSize => _pageSize;
  
  // Getters sắp xếp
  ProductSortField get sortField => _sortField;
  SortDirection get sortDirection => _sortDirection;
  
  // Lấy tất cả sản phẩm với phân trang
  Future<void> fetchProducts({int page = 0}) async {
    _status = ProductStatus.loading;
    _currentPage = page;
    notifyListeners();
    
    try {
      final response = await _repository.getProducts(page: page, size: _pageSize);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
        
        // Lưu thông tin phân trang
        if (response.meta != null) {
          _totalPages = _getIntValue(response.meta!['totalPages'], 0);
          _totalItems = _getIntValue(response.meta!['totalItems'], 0);
          _currentPage = _getIntValue(response.meta!['currentPage'], 0);
        }
        
        // Sắp xếp sản phẩm nếu cần
        _sortProducts();
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
  
  // Tìm kiếm sản phẩm với phân trang
  Future<void> searchProducts(String query, {int page = 0}) async {
    _status = ProductStatus.loading;
    _searchQuery = query;
    _currentPage = page;
    
    // Reset bộ lọc
    _currentBrandId = null;
    _currentTypeId = null;
    _currentTagId = null;
    
    notifyListeners();
    
    try {
      final response = await _repository.searchProducts(query, page: page, size: _pageSize);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
        
        // Lưu thông tin phân trang
        if (response.meta != null) {
          _totalPages = _getIntValue(response.meta!['totalPages'], 0);
          _totalItems = _getIntValue(response.meta!['totalItems'], 0);
          _currentPage = _getIntValue(response.meta!['currentPage'], 0);
        }
        
        // Sắp xếp sản phẩm nếu cần
        _sortProducts();
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
  
  // Lấy sản phẩm theo thương hiệu với phân trang
  Future<void> getProductsByBrand(String brandId, {int page = 0}) async {
    _status = ProductStatus.loading;
    _currentBrandId = brandId;
    _currentPage = page;
    
    // Reset các bộ lọc khác
    _searchQuery = '';
    _currentTypeId = null;
    _currentTagId = null;
    
    notifyListeners();
    
    try {
      final response = await _repository.getProductsByBrand(brandId, page: page, size: _pageSize);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
        
        // Lưu thông tin phân trang
        if (response.meta != null) {
          _totalPages = _getIntValue(response.meta!['totalPages'], 0);
          _totalItems = _getIntValue(response.meta!['totalItems'], 0);
          _currentPage = _getIntValue(response.meta!['currentPage'], 0);
        }
        
        // Sắp xếp sản phẩm nếu cần
        _sortProducts();
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
  
  // Lấy sản phẩm theo loại với phân trang
  Future<void> getProductsByType(String typeId, {int page = 0}) async {
    _status = ProductStatus.loading;
    _currentTypeId = typeId;
    _currentPage = page;
    
    // Reset các bộ lọc khác
    _searchQuery = '';
    _currentBrandId = null;
    _currentTagId = null;
    
    notifyListeners();
    
    try {
      final response = await _repository.getProductsByType(typeId, page: page, size: _pageSize);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
        
        // Lưu thông tin phân trang
        if (response.meta != null) {
          _totalPages = response.meta!['totalPages'] ?? 0;
          _totalItems = response.meta!['totalItems'] ?? 0;
          _currentPage = response.meta!['currentPage'] ?? 0;
        }
        
        // Sắp xếp sản phẩm nếu cần
        _sortProducts();
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
  
  // Lấy sản phẩm theo tag với phân trang
  Future<void> getProductsByTag(String tagId, {int page = 0}) async {
    _status = ProductStatus.loading;
    _currentTagId = tagId;
    _currentPage = page;
    
    // Reset các bộ lọc khác
    _searchQuery = '';
    _currentBrandId = null;
    _currentTypeId = null;
    
    notifyListeners();
    
    try {
      final response = await _repository.getProductsByTag(tagId, page: page, size: _pageSize);
      
      if (response.data != null) {
        _products = response.data!;
        _status = ProductStatus.loaded;
        
        // Lưu thông tin phân trang
        if (response.meta != null) {
          _totalPages = _getIntValue(response.meta!['totalPages'], 0);
          _totalItems = _getIntValue(response.meta!['totalItems'], 0);
          _currentPage = _getIntValue(response.meta!['currentPage'], 0);
        }
        
        // Sắp xếp sản phẩm nếu cần
        _sortProducts();
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
  
  // Helper để xử lý an toàn kiểu dữ liệu từ API
  int _getIntValue(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }
  
  // Đặt thông tin sắp xếp
  void setSorting(ProductSortField field, SortDirection direction) {
    _sortField = field;
    _sortDirection = direction;
    
    // Sắp xếp lại danh sách sản phẩm hiện tại
    _sortProducts();
    
    notifyListeners();
  }
  
  // Sắp xếp danh sách sản phẩm hiện tại
  void _sortProducts() {
    if (_products.isEmpty) return;
    
    switch (_sortField) {
      case ProductSortField.createdAt:
        // Tạm thời nếu sản phẩm không có createdAt, chúng ta sẽ giả định là theo ID
        _products.sort((a, b) {
          if (_sortDirection == SortDirection.asc) {
            return a.id.compareTo(b.id);
          } else {
            return b.id.compareTo(a.id);
          }
        });
        break;
      case ProductSortField.price:
        _products.sort((a, b) {
          if (_sortDirection == SortDirection.asc) {
            return a.price.compareTo(b.price);
          } else {
            return b.price.compareTo(a.price);
          }
        });
        break;
      case ProductSortField.name:
        _products.sort((a, b) {
          if (_sortDirection == SortDirection.asc) {
            return a.name.compareTo(b.name);
          } else {
            return b.name.compareTo(a.name);
          }
        });
        break;
      case ProductSortField.quantity:
        _products.sort((a, b) {
          if (_sortDirection == SortDirection.asc) {
            return a.quantity.compareTo(b.quantity);
          } else {
            return b.quantity.compareTo(a.quantity);
          }
        });
        break;
      case ProductSortField.soldCount:
        _products.sort((a, b) {
          if (_sortDirection == SortDirection.asc) {
            return a.soldCount.compareTo(b.soldCount);
          } else {
            return b.soldCount.compareTo(a.soldCount);
          }
        });
        break;
    }
  }
  
  // Reset bộ lọc và tải lại danh sách sản phẩm
  Future<void> resetFilters() async {
    _searchQuery = '';
    _currentBrandId = null;
    _currentTypeId = null;
    _currentTagId = null;
    _currentPage = 0;
    await fetchProducts();
  }
  
  // Đặt kích thước trang
  void setPageSize(int size) {
    _pageSize = size;
    fetchProducts(page: 0); // Tải lại trang đầu tiên với kích thước mới
  }
  
  // Chuyển đến trang cụ thể
  Future<void> goToPage(int page) async {
    if (page < 0 || page >= _totalPages) return;
    
    if (_searchQuery.isNotEmpty) {
      await searchProducts(_searchQuery, page: page);
    } else if (_currentBrandId != null) {
      await getProductsByBrand(_currentBrandId!, page: page);
    } else if (_currentTypeId != null) {
      await getProductsByType(_currentTypeId!, page: page);
    } else if (_currentTagId != null) {
      await getProductsByTag(_currentTagId!, page: page);
    } else {
      await fetchProducts(page: page);
    }
  }
  
  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  // Tạo sản phẩm mới
  Future<bool> createProduct(Product product, {XFile? imageFile}) async {
    _status = ProductStatus.loading;
    notifyListeners();
    
    try {
      final response = await _repository.createProduct(product, imageFile: imageFile);
      
      if (response.status == 200 && response.data != null) {
        // Thêm sản phẩm mới vào danh sách nếu đang ở trang đầu
        if (_currentPage == 0) {
          _products.insert(0, response.data!);
          // Sắp xếp lại nếu cần
          _sortProducts();
        }
        _currentProduct = response.data;
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
  Future<bool> updateProduct(String id, Product product, {XFile? imageFile}) async {
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
        
        // Sắp xếp lại nếu cần
        _sortProducts();
        
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
        
        // Nếu xóa sản phẩm hiện tại, đặt currentProduct thành null
        if (_currentProduct?.id == id) {
          _currentProduct = null;
        }
        
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