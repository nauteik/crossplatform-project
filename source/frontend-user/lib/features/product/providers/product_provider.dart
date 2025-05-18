import 'package:flutter/material.dart';
import '../../../data/model/product_model.dart';
import '../../../data/respository/product_repository.dart';
import '../../../data/respository/review_repository.dart';
import 'dart:developer' as developer;

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final ReviewRepository _reviewRepository = ReviewRepository();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  ProductModel? _currentProduct;
  ProductStatus _status = ProductStatus.initial;
  String _errorMessage = '';
  String _currentCategory = 'all';
  
  // Pagination properties
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalItems = 0;
  int _totalPages = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  ProductModel? get currentProduct => _currentProduct;
  ProductStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Lấy tất cả sản phẩm
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      developer.log("Fetching all products");
      final response = await _repository.getProducts();

      if (response.data != null) {
        _products = response.data!;
        _filteredProducts = response.data!;
        _status = ProductStatus.loaded;
        
        developer.log("Fetched ${_products.length} products");
        if (_products.isNotEmpty) {
          developer.log("Sample product: ${_products.first.name}");
          developer.log("Sample product type: ${_products.first.productType}");
        }
        
        // Lấy thông tin rating cho các sản phẩm
        await _fetchRatingsForProducts();
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        developer.log("Error fetching products: ${response.message}");
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception fetching products: $e");
    }

    notifyListeners();
  }
  
  // Lấy sản phẩm theo phân trang (tải trang đầu tiên)
  Future<void> fetchPagedProducts() async {
    _currentPage = 0; // Reset to first page
    _status = ProductStatus.loading;
    _isLoadingMore = false;
    _hasMoreData = true;
    notifyListeners();

    try {
      developer.log("Fetching paged products, page: $_currentPage, size: $_pageSize");
      final response = await _repository.getPagedProducts(_currentPage, _pageSize);

      if (response.data != null) {
        final pageData = response.data!;
        _products = List<ProductModel>.from((pageData['products'] as List)
            .map((item) => ProductModel.fromJson(item)));
        _filteredProducts = [..._products];
        _currentPage = pageData['currentPage'];
        _totalItems = pageData['totalItems'];
        _totalPages = pageData['totalPages'];
        _hasMoreData = _currentPage < _totalPages - 1;
        _status = ProductStatus.loaded;
        
        developer.log("Fetched ${_products.length} products, total: $_totalItems, pages: $_totalPages");
        
        // Lấy thông tin rating cho các sản phẩm
        await _fetchRatingsForProducts();
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        developer.log("Error fetching paged products: ${response.message}");
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception fetching paged products: $e");
    }

    notifyListeners();
  }
  
  // Tải thêm sản phẩm (trang tiếp theo)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData || _status == ProductStatus.loading) {
      developer.log("Không tải thêm sản phẩm: isLoadingMore=$_isLoadingMore, hasMoreData=$_hasMoreData, status=$_status");
      return;
    }
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      final nextPage = _currentPage + 1;
      developer.log("Loading more products, page: $nextPage, size: $_pageSize");
      
      final response = await _repository.getPagedProducts(nextPage, _pageSize);
      
      if (response.data != null) {
        final pageData = response.data!;
        
        // Kiểm tra xem có dữ liệu sản phẩm không
        if (pageData.containsKey('products') && pageData['products'] is List) {
          final newProducts = List<ProductModel>.from((pageData['products'] as List)
              .map((item) => ProductModel.fromJson(item)));
          
          if (newProducts.isNotEmpty) {
            _products.addAll(newProducts);
            _filteredProducts = [..._products]; // Update filtered products too
            _currentPage = pageData['currentPage'] ?? _currentPage + 1;
            _totalItems = pageData['totalItems'] ?? _totalItems;
            _totalPages = pageData['totalPages'] ?? _totalPages;
            _hasMoreData = _currentPage < _totalPages - 1;
            
            developer.log("Added ${newProducts.length} more products, total: ${_products.length}, currentPage: $_currentPage, totalPages: $_totalPages");
            
            // Lấy thông tin rating cho các sản phẩm mới
            await _fetchRatingsForNewProducts(newProducts);
          } else {
            _hasMoreData = false;
            developer.log("No more products to load (empty list returned)");
          }
        } else {
          _hasMoreData = false;
          developer.log("Invalid response format: 'products' key missing or not a list");
        }
      } else {
        developer.log("Error loading more products: ${response.message}");
        throw Exception("Error loading more products: ${response.message}");
      }
    } catch (e) {
      developer.log("Exception loading more products: $e");
      rethrow; // Rethrow để caller có thể xử lý
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết sản phẩm theo ID
  Future<void> getProductById(String id) async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      developer.log("Fetching product with ID: $id");
      final response = await _repository.getProductById(id);

      if (response.data != null) {
        _currentProduct = response.data;
        _status = ProductStatus.loaded;
        developer.log("Successfully fetched product: ${_currentProduct?.name}");
        
        // Lấy thông tin rating cho sản phẩm hiện tại
        await _fetchRatingForCurrentProduct();
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        developer.log("Error fetching product by ID: ${response.message}");
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception fetching product by ID: $e");
    }

    notifyListeners();
  }

  // Tìm kiếm sản phẩm
  Future<void> searchProducts(String query) async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      developer.log("Searching products with query: $query");
      final response = await _repository.searchProducts(query);

      if (response.data != null) {
        _products = response.data!;
        _filteredProducts = response.data!;
        _status = ProductStatus.loaded;
        developer.log("Found ${_products.length} products matching query");
        
        // Lấy thông tin rating cho các sản phẩm tìm thấy
        await _fetchRatingsForProducts();
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        developer.log("Error searching products: ${response.message}");
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception searching products: $e");
    }

    notifyListeners();
  }

  // Lấy sản phẩm theo thương hiệu
  Future<void> getProductsByBrand(String brandId) async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      developer.log("Fetching products by brand ID: $brandId");
      final response = await _repository.getProductsByBrand(brandId);

      if (response.data != null) {
        _products = response.data!;
        _filteredProducts = response.data!;
        _status = ProductStatus.loaded;
        developer.log("Found ${_products.length} products for brand");
        
        // Lấy thông tin rating cho các sản phẩm
        await _fetchRatingsForProducts();
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        developer.log("Error fetching products by brand: ${response.message}");
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception fetching products by brand: $e");
    }

    notifyListeners();
  }

  // Lấy sản phẩm theo loại
  Future<void> getProductsByType(String typeId) async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      developer.log("Fetching products by type ID: $typeId");
      final response = await _repository.getProductsByType(typeId);

      if (response.data != null) {
        _products = response.data!;
        _filteredProducts = response.data!;
        _status = ProductStatus.loaded;
        developer.log("Found ${_products.length} products for type");
        
        // Lấy thông tin rating cho các sản phẩm
        await _fetchRatingsForProducts();
      } else {
        _status = ProductStatus.error;
        _errorMessage = response.message;
        developer.log("Error fetching products by type: ${response.message}");
      }
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
      developer.log("Exception fetching products by brand: $e");
    }

    notifyListeners();
  }

  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }
  
  // Lấy danh sách hình ảnh của sản phẩm
  Future<List<String>> getProductImages(String productId) async {
    try {
      developer.log("Fetching images for product ID: $productId");
      final response = await _repository.getProductImages(productId);
      if (response.data != null) {
        developer.log("Retrieved ${response.data!.length} images");
        return response.data!;
      }
      developer.log("No images found for product");
      return [];
    } catch (e) {
      developer.log("Exception fetching product images: $e");
      return [];
    }
  }
  
  // Lấy ảnh chính của sản phẩm
  Future<String?> getPrimaryImage(String productId) async {
    try {
      developer.log("Fetching primary image for product ID: $productId");
      final response = await _repository.getPrimaryImage(productId);
      developer.log("Primary image: ${response.data}");
      return response.data;
    } catch (e) {
      developer.log("Exception fetching primary image: $e");
      return null;
    }
  }

  // Phương thức để cập nhật danh sách sản phẩm đã lọc
  void setFilteredProducts(List<dynamic> products) {
    _filteredProducts = List<ProductModel>.from(products);
    notifyListeners();
  }

  // Phương thức để lấy danh sách sản phẩm đã lọc
  List<dynamic> getFilteredProducts() {
    return _filteredProducts;
  }
  
  // Phương thức mới để lấy rating cho tất cả sản phẩm
  Future<void> _fetchRatingsForProducts() async {
    try {
      if (_products.isEmpty) return;
      
      // Sử dụng Future.wait để lấy rating cho tất cả sản phẩm song song
      // Để tránh quá tải server, chia nhỏ việc lấy rating thành nhiều batch
      final int batchSize = 20;
      int processedCount = 0;
      
      while (processedCount < _products.length) {
        // Lấy batch tiếp theo
        final endIndex = (processedCount + batchSize < _products.length) 
            ? processedCount + batchSize 
            : _products.length;
            
        final batch = _products.sublist(processedCount, endIndex);
        
        final futures = batch.map((product) async {
          try {
            final response = await _reviewRepository.getReviewSummary(product.id);
            if (response.data != null && response.status > 0) {
              // Tìm sản phẩm trong danh sách và cập nhật rating
              final index = _products.indexWhere((p) => p.id == product.id);
              if (index != -1) {
                final averageRating = response.data!['averageRating'] != null 
                    ? (response.data!['averageRating'] as num).toDouble()
                    : 0.0;
                
                // Tạo bản sao mới với rating đã cập nhật
                final updatedProduct = ProductModel(
                  id: _products[index].id,
                  name: _products[index].name,
                  price: _products[index].price,
                  quantity: _products[index].quantity,
                  description: _products[index].description,
                  primaryImageUrl: _products[index].primaryImageUrl,
                  imageUrls: _products[index].imageUrls,
                  soldCount: _products[index].soldCount,
                  discountPercent: _products[index].discountPercent,
                  brand: _products[index].brand,
                  productType: _products[index].productType,
                  specifications: _products[index].specifications,
                  createdAt: _products[index].createdAt,
                  tags: _products[index].tags,
                  averageRating: averageRating,
                );
                
                _products[index] = updatedProduct;
                
                // Cập nhật lại filtered products
                final filteredIndex = _filteredProducts.indexWhere((p) => p.id == product.id);
                if (filteredIndex != -1) {
                  _filteredProducts[filteredIndex] = updatedProduct;
                }
              }
            }
          } catch (e) {
            developer.log("Error fetching rating for product ${product.id}: $e");
          }
        }).toList();
        
        await Future.wait(futures);
        
        // Thông báo UI cập nhật sau mỗi batch
        notifyListeners();
        
        // Tăng số lượng sản phẩm đã xử lý
        processedCount += batchSize;
      }
    } catch (e) {
      developer.log("Error in _fetchRatingsForProducts: $e");
    }
  }
  
  // Phương thức để lấy rating cho danh sách sản phẩm mới
  Future<void> _fetchRatingsForNewProducts(List<ProductModel> newProducts) async {
    try {
      if (newProducts.isEmpty) return;
      
      final futures = newProducts.map((product) async {
        try {
          final response = await _reviewRepository.getReviewSummary(product.id);
          if (response.data != null && response.status > 0) {
            // Tìm sản phẩm trong danh sách và cập nhật rating
            final index = _products.indexWhere((p) => p.id == product.id);
            if (index != -1) {
              final averageRating = response.data!['averageRating'] != null 
                  ? (response.data!['averageRating'] as num).toDouble()
                  : 0.0;
              
              // Tạo bản sao mới với rating đã cập nhật
              final updatedProduct = ProductModel(
                id: _products[index].id,
                name: _products[index].name,
                price: _products[index].price,
                quantity: _products[index].quantity,
                description: _products[index].description,
                primaryImageUrl: _products[index].primaryImageUrl,
                imageUrls: _products[index].imageUrls,
                soldCount: _products[index].soldCount,
                discountPercent: _products[index].discountPercent,
                brand: _products[index].brand,
                productType: _products[index].productType,
                specifications: _products[index].specifications,
                createdAt: _products[index].createdAt,
                tags: _products[index].tags,
                averageRating: averageRating,
              );
              
              _products[index] = updatedProduct;
              
              // Cập nhật lại filtered products
              final filteredIndex = _filteredProducts.indexWhere((p) => p.id == product.id);
              if (filteredIndex != -1) {
                _filteredProducts[filteredIndex] = updatedProduct;
              }
            }
          }
        } catch (e) {
          developer.log("Error fetching rating for product ${product.id}: $e");
        }
      }).toList();
      
      await Future.wait(futures);
      
      // Thông báo UI cập nhật
      notifyListeners();
      
    } catch (e) {
      developer.log("Error in _fetchRatingsForNewProducts: $e");
    }
  }
  
  // Phương thức để lấy rating cho sản phẩm hiện tại
  Future<void> _fetchRatingForCurrentProduct() async {
    try {
      if (_currentProduct == null) return;
      
      final response = await _reviewRepository.getReviewSummary(_currentProduct!.id);
      if (response.data != null && response.status > 0) {
        final averageRating = response.data!['averageRating'] != null 
            ? (response.data!['averageRating'] as num).toDouble()
            : 0.0;
        
        // Tạo bản sao mới với rating đã cập nhật
        _currentProduct = ProductModel(
          id: _currentProduct!.id,
          name: _currentProduct!.name,
          price: _currentProduct!.price,
          quantity: _currentProduct!.quantity,
          description: _currentProduct!.description,
          primaryImageUrl: _currentProduct!.primaryImageUrl,
          imageUrls: _currentProduct!.imageUrls,
          soldCount: _currentProduct!.soldCount,
          discountPercent: _currentProduct!.discountPercent,
          brand: _currentProduct!.brand,
          productType: _currentProduct!.productType,
          specifications: _currentProduct!.specifications,
          createdAt: _currentProduct!.createdAt,
          tags: _currentProduct!.tags,
          averageRating: averageRating,
        );
        
        // Thông báo UI cập nhật
        notifyListeners();
      }
    } catch (e) {
      developer.log("Error in _fetchRatingForCurrentProduct: $e");
    }
  }
}
