import 'package:frontend_user/data/model/api_response_model.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/data/respository/cart_repository.dart';
import 'package:frontend_user/features/cart/observer/cart_observer.dart';
import 'package:frontend_user/features/cart/observer/cart_subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartManager implements CartSubject {
  final List<CartObserver> _observers = [];
  final List<CartItemModel> _items = [];
  final CartRepository _repository = CartRepository();

  static final CartManager _instance = CartManager._internal();

  factory CartManager() {
    return _instance;
  }

  CartManager._internal();

  @override
  void attach(CartObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  @override
  void detach(CartObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notify() {
    for (var observer in _observers) {
      observer.update(_items);
    }
  }

  Future<ApiResponse<dynamic>> addItem(CartItemModel item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _items.clear();
        await prefs.setString('cart', '[]');
        return ApiResponse(
          status: 0,
          message: 'User not logged in. Cannot load cart from backend.',
          data: null,
        );
      }

      final response = await _repository.addToCart(
          userId: userId,
          productId: item.id,
          quantity: item.quantity,
          price: item.price,
          name: item.name,
          imageUrl: item.imageUrl);

      if (response.status == 1) {
        _items.add(item);
        notify();
      }
      return response;
    } catch (e) {
      print('Error adding item: $e');
      return ApiResponse(
        status: 0,
        message: 'An error occurred while adding the item.',
        data: null,
      );
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        await _repository.removeFromCart(userId, productId);
        _items.removeWhere((item) => item.id == productId);
        notify();
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  void setItems(List<CartItemModel> items) {
    _items.clear();
    _items.addAll(items);
    notify();
  }

  void clearItems() {
    _items.clear();
    notify();
  }

  double getTotalPrice() {
    return _items.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  Future<void> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _repository.getCart(userId);

      if (response.status == 1 && response.data != null) {
        final cartData = response.data as Map<String, dynamic>;
        final data = cartData['data'];
        final List<dynamic> itemMaps = data['items'];

        final List<CartItemModel> loadedItems = itemMaps
            .map((itemMap) =>
                CartItemModel.fromJson(itemMap as Map<String, dynamic>))
            .toList();

        setItems(loadedItems);
        notify();
      }
    } catch (e) {
      print('Error fetching cart: $e');
      rethrow;
    }
  }

  List<CartItemModel> get items => _items;
}
