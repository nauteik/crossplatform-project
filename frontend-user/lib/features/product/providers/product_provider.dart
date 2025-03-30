import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
  final int soldCount;
  final double discountPercent;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.soldCount = 0,
    this.discountPercent = 0.0,
    this.isAvailable = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      category: json['category'],
      soldCount: json['soldCount'] ?? 0,
      discountPercent: json['discountPercent'] ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _currentCategory = 'all';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get currentCategory => _currentCategory;

  List<Product> get featuredProducts {
    return _products.where((product) => product.discountPercent > 0).toList();
  }

  List<Product> getProductsByCategory(String category) {
    if (category == 'all') {
      return _products;
    }
    return _products.where((product) => product.category == category).toList();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Giả lập API call
      await Future.delayed(Duration(seconds: 1));
      
      // Mock data
      _products = [
        Product(
          id: '1',
          name: 'PC Gaming RTX 3060',
          price: 25000000,
          imageUrl: 'https://example.com/pc1.jpg',
          description: 'PC Gaming với Card đồ họa RTX 3060',
          category: 'PC GAMING',
          soldCount: 45,
          discountPercent: 10.0,
        ),
        Product(
          id: '2',
          name: 'PC Văn Phòng Core i5',
          price: 12000000,
          imageUrl: 'https://example.com/pc2.jpg',
          description: 'PC văn phòng với CPU Intel Core i5',
          category: 'PC VĂN PHÒNG',
          soldCount: 67,
          discountPercent: 5.0,
        ),
        // Thêm các sản phẩm khác
      ];
    } catch (e) {
      print('Lỗi tải sản phẩm: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
} 