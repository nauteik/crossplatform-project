import 'package:flutter/foundation.dart';
import 'package:frontend_user/data/model/api_response_model.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/features/cart/observer/cart_concrete_observer.dart';
import 'package:frontend_user/features/cart/observer/cart_manager.dart';
import 'package:frontend_user/data/respository/cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final CartManager _cartManager = CartManager();
  late CartBadgeObserver _badgeObserver;
  late CartTotalObserver _totalObserver;
  final CartRepository _repository = CartRepository();
  
  // State variables for cart
  int _itemCount = 0;
  double _total = 0.0;
  
  // State variable for selected items
  final Set<String> _selectedItemIds = {};

  CartProvider() {
    _initializeObservers();
  }

  void _initializeObservers() {
    _badgeObserver = CartBadgeObserver((count) {
      _itemCount = count;
      notifyListeners();
    });

    _totalObserver = CartTotalObserver((total) {
      _total = total;
      notifyListeners();
    });

    _cartManager.attach(_badgeObserver);
    _cartManager.attach(_totalObserver);
  }

  List<CartItemModel> get items => _cartManager.items;
  int get itemCount => _itemCount;
  double get total => _total;
  
  // Get only selected items
  List<CartItemModel> get selectedItems {
    return items.where((item) => _selectedItemIds.contains(item.id)).toList();
  }
  
  // Get total price of selected items
  double get selectedItemsTotalPrice {
    double total = 0.0;
    for (var item in selectedItems) {
      total += item.price * item.quantity;
    }
    return total;
  }
  
  // Check if an item is selected
  bool isItemSelected(String productId) {
    return _selectedItemIds.contains(productId);
  }

  Future<ApiResponse<dynamic>> addItem(CartItemModel item) async {
    return await _cartManager.addItem(item);
  }

  Future<void> removeItem(String productId) async {
    await _cartManager.removeItem(productId);
    
    // Also remove from selected items if present
    if (_selectedItemIds.contains(productId)) {
      _selectedItemIds.remove(productId);
      notifyListeners();
    }
  }

  double get totalPrice {
    return _cartManager.getTotalPrice();
  }

  Future<void> fetchCart() async {
    try {
      await _cartManager.fetchCart();
      // Clear selected items when fetching a new cart
      _selectedItemIds.clear();
      notifyListeners();
    } catch (e) {
      print('Error fetching cart: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    _cartManager.clearItems();
    _selectedItemIds.clear(); // Also clear selections
    notifyListeners();
  }
  
  // Toggle selection of a cart item
  void toggleItemSelection(String productId) {
    if (_selectedItemIds.contains(productId)) {
      _selectedItemIds.remove(productId);
    } else {
      _selectedItemIds.add(productId);
    }
    notifyListeners();
  }
  
  // Select a specific item
  void selectItem(String productId) {
    if (!_selectedItemIds.contains(productId)) {
      _selectedItemIds.add(productId);
      notifyListeners();
    }
  }
  
  // Deselect a specific item
  void deselectItem(String productId) {
    if (_selectedItemIds.contains(productId)) {
      _selectedItemIds.remove(productId);
      notifyListeners();
    }
  }
  
  // Clear all selections
  void clearSelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      _selectedItemIds.clear();
      notifyListeners();
    }
  }
  
  // Add an item and select it (for "Buy Now" functionality)
  Future<ApiResponse<dynamic>> addItemAndSelect(CartItemModel item) async {
    final response = await addItem(item);
    if (response.status == 1) { // If successfully added
      selectItem(item.id);
    }
    return response;
  }
  
  // Remove multiple items (after payment)
  Future<void> removePaidItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;
    
    // Use the more efficient bulk removal method
    await _cartManager.removeMultipleItems(itemIds);
    
    // Also clear these items from the selected items set
    for (final id in itemIds) {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _cartManager.detach(_badgeObserver);
    _cartManager.detach(_totalObserver);
    super.dispose();
  }
}
