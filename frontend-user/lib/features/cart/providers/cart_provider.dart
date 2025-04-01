import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<ProductModel> _items = [];
  
  List<ProductModel> get items => _items;
  int get itemCount => _items.length;
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  CartProvider() {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart') ?? '[]';
      final cartList = jsonDecode(cartJson) as List;
      _items = cartList.map((item) => ProductModel.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải giỏ hàng: $e');
    }
  }

  Future<void> _saveCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      print('Lỗi khi lưu giỏ hàng: $e');
    }
  }
  
  void addItem(ProductModel product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(product);
    }
    
    _saveCartItems();
    notifyListeners();
  }
  
  void removeItem(String productId) {
    _items.removeWhere((item) => item.id == productId);
    _saveCartItems();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveCartItems();
      notifyListeners();
    }
  }
  
  void clearCart() {
    _items.clear();
    _saveCartItems();
    notifyListeners();
  }
} 