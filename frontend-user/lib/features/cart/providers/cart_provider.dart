import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend_user/data/model/api_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_user/core/constants/api_constants.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/data/respository/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  final CartRepository _repository = CartRepository();

  List<CartItemModel> get items => _items;
  int get itemCount => _items.length;

  double get totalPrice {
    double calculatedTotal = 0.0;
    for (var item in _items) {
      calculatedTotal += item.price * item.quantity;
    }
    return calculatedTotal;
  }

  Future<void> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _items.clear();
        await prefs.setString('cart', '[]');
        notifyListeners();
        print('User not logged in. Cannot load cart from backend.');
        return;
      }

      final response = await _repository.getCart(userId);

      if (response.status == 1 && response.data != null) {
        final cartData = response.data as Map<String, dynamic>;
        final Map<String, dynamic> data = cartData['data'];
        final List<dynamic> itemMaps = data['items'];

        final List<CartItemModel> loadedItems = itemMaps.map((itemMap) {
          return CartItemModel.fromJson(itemMap as Map<String, dynamic>);
        }).toList();

        _items.clear();
        _items.addAll(loadedItems);

        for (CartItemModel item in _items) {
          print(item.toString());
        }

        await _saveCartItems();
        notifyListeners();

        print('Cart items loaded successfully from backend.');
      } else if (response.status == 0 &&
          response.data == null &&
          response.message.contains('not found')) {
        print(
            'Cart not found on backend for user $userId. Initializing empty local cart.');
        _items.clear();
        await prefs.setString('cart', '[]');
        notifyListeners();
      } else {
        print('Failed to load cart from backend: ${response.message}');
        throw Exception('Failed to load cart from server: ${response.message}');
      }
    } catch (e) {
      print('Error loading cart items: $e');
      _items.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart', '[]');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      print('Error saving cart items: $e');
      rethrow;
    }
  }

  Future<ApiResponse<dynamic>> addItem(CartItemModel cartItem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Add to backend first
      ApiResponse<dynamic> response = await _repository.addToCart(
        userId: userId,
        productId: cartItem.id,
        name: cartItem.name,
        price: cartItem.price,
        imageUrl: cartItem.imageUrl,
        quantity: cartItem.quantity,
      );

      // If backend successful, update local state
      final existingIndex = _items.indexWhere((item) => item.id == cartItem.id);
      if (existingIndex >= 0) {
        _items[existingIndex].quantity += cartItem.quantity;
      } else {
        _items.add(cartItem);
      }

      await _saveCartItems();
      notifyListeners();
      return response;
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final response = await http.delete(
          Uri.parse(
              '${ApiConstants.baseApiUrl}/api/cart/$userId/items/$productId'),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to remove item from server');
        }
      }

      _items.removeWhere((item) => item.id == productId);
      await _saveCartItems(); // Only save locally
      notifyListeners();
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseApiUrl}/api/cart/$userId'),
        );

        if (response.statusCode != 204) {
          throw Exception('Failed to clear cart on server');
        }
      }

      _items.clear();
      await prefs.setString('cart', '[]');
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
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
}
