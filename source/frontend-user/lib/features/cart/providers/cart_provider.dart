import 'package:flutter/foundation.dart';
import 'package:frontend_user/data/model/api_response_model.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/features/cart/observer/cart_concrete_observer.dart';
import 'package:frontend_user/features/cart/observer/cart_manager.dart';
import 'package:frontend_user/data/respository/cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  
  // Flag to track if user is authenticated
  bool _isAuthenticated = false;

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
  
  // Set authentication status
  void setAuthenticated(bool status) {
    _isAuthenticated = status;
    // Khi đăng nhập, đồng bộ giỏ hàng local lên server
    if (status) {
      _syncLocalCartToServer();
    }
  }

  Future<ApiResponse<dynamic>> addItem(CartItemModel item) async {
    if (_isAuthenticated) {
      // Đã đăng nhập, thêm vào server
      return await _cartManager.addItem(item);
    } else {
      // Chưa đăng nhập, lưu local
      _addItemToLocalCart(item);
      return ApiResponse(
        status: 1,
        message: 'Đã thêm vào giỏ hàng',
        data: null,
      );
    }
  }
  
  // Thêm sản phẩm vào giỏ hàng local
  Future<void> _addItemToLocalCart(CartItemModel item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> localCart = prefs.getStringList('local_cart') ?? [];
    
    // Kiểm tra xem sản phẩm đã tồn tại chưa
    bool itemExists = false;
    List<CartItemModel> cartItems = [];
    
    for (String itemJson in localCart) {
      CartItemModel existingItem = CartItemModel.fromJson(json.decode(itemJson));
      if (existingItem.id == item.id) {
        // Cập nhật số lượng
        existingItem.quantity += item.quantity;
        itemExists = true;
      }
      cartItems.add(existingItem);
    }
    
    // Nếu chưa tồn tại, thêm mới
    if (!itemExists) {
      cartItems.add(item);
    }
    
    // Lưu lại giỏ hàng
    localCart = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('local_cart', localCart);
    
    // Cập nhật giỏ hàng trong memory
    _cartManager.setItems(cartItems);
  }
  
  // Đồng bộ giỏ hàng local lên server khi đăng nhập
  Future<void> _syncLocalCartToServer() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> localCart = prefs.getStringList('local_cart') ?? [];
      
      if (localCart.isEmpty) return;
      
      // Lấy danh sách các sản phẩm trong giỏ hàng local
      List<CartItemModel> cartItems = localCart
          .map((itemJson) => CartItemModel.fromJson(json.decode(itemJson)))
          .toList();
      
      // Thêm từng sản phẩm vào server
      for (var item in cartItems) {
        await _cartManager.addItem(item);
      }
      
      // Xóa giỏ hàng local sau khi đồng bộ
      await prefs.remove('local_cart');
    } catch (e) {
      print('Error syncing local cart to server: $e');
    }
  }

  Future<void> removeItem(String productId) async {
    if (_isAuthenticated) {
      // Đã đăng nhập, xóa từ server
      await _cartManager.removeItem(productId);
    } else {
      // Chưa đăng nhập, xóa từ local
      await _removeItemFromLocalCart(productId);
    }
    
    // Also remove from selected items if present
    if (_selectedItemIds.contains(productId)) {
      _selectedItemIds.remove(productId);
      notifyListeners();
    }
  }
  
  // Xóa sản phẩm khỏi giỏ hàng local
  Future<void> _removeItemFromLocalCart(String productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> localCart = prefs.getStringList('local_cart') ?? [];
    
    List<CartItemModel> cartItems = localCart
        .map((itemJson) => CartItemModel.fromJson(json.decode(itemJson)))
        .toList();
    
    // Lọc bỏ sản phẩm cần xóa
    cartItems = cartItems.where((item) => item.id != productId).toList();
    
    // Lưu lại giỏ hàng
    localCart = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('local_cart', localCart);
    
    // Cập nhật giỏ hàng trong memory
    _cartManager.setItems(cartItems);
  }

  double get totalPrice {
    return _cartManager.getTotalPrice();
  }

  Future<void> fetchCart() async {
    try {
      if (_isAuthenticated) {
        // Đã đăng nhập, lấy từ server
        await _cartManager.fetchCart();
      } else {
        // Chưa đăng nhập, lấy từ local
        await _loadLocalCart();
      }
      
      // Clear selected items when fetching a new cart
      _selectedItemIds.clear();
      notifyListeners();
    } catch (e) {
      print('Error fetching cart: $e');
      rethrow;
    }
  }
  
  // Tải giỏ hàng từ bộ nhớ local
  Future<void> _loadLocalCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> localCart = prefs.getStringList('local_cart') ?? [];
      
      List<CartItemModel> cartItems = localCart
          .map((itemJson) => CartItemModel.fromJson(json.decode(itemJson)))
          .toList();
      
      // Cập nhật giỏ hàng trong memory
      _cartManager.setItems(cartItems);
    } catch (e) {
      print('Error loading local cart: $e');
    }
  }

  Future<void> clearCart() async {
    if (_isAuthenticated) {
      // Đã đăng nhập, xóa từ server
      _cartManager.clearItems();
    } else {
      // Chưa đăng nhập, xóa từ local
      await _clearLocalCart();
    }
    
    _selectedItemIds.clear(); // Also clear selections
    notifyListeners();
  }
  
  // Xóa toàn bộ giỏ hàng local
  Future<void> _clearLocalCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_cart');
      
      // Cập nhật giỏ hàng trong memory
      _cartManager.setItems([]);
    } catch (e) {
      print('Error clearing local cart: $e');
    }
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
  
  // Update quantity of an existing cart item
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) return; // Don't allow quantity less than 1
    
    try {
      if (_isAuthenticated) {
        // Đã đăng nhập, cập nhật trên server
        await _cartManager.updateItemQuantity(productId, newQuantity);
      } else {
        // Chưa đăng nhập, cập nhật local
        await _updateLocalItemQuantity(productId, newQuantity);
      }
      
      // Notify listeners about the change
      notifyListeners();
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }
  
  // Cập nhật số lượng sản phẩm trong giỏ hàng local
  Future<void> _updateLocalItemQuantity(String productId, int newQuantity) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> localCart = prefs.getStringList('local_cart') ?? [];
    
    List<CartItemModel> cartItems = localCart
        .map((itemJson) => CartItemModel.fromJson(json.decode(itemJson)))
        .toList();
    
    // Tìm và cập nhật số lượng
    for (var i = 0; i < cartItems.length; i++) {
      if (cartItems[i].id == productId) {
        cartItems[i].quantity = newQuantity;
        break;
      }
    }
    
    // Lưu lại giỏ hàng
    localCart = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('local_cart', localCart);
    
    // Cập nhật giỏ hàng trong memory
    _cartManager.setItems(cartItems);
  }
  
  // Remove multiple items (after payment)
  Future<void> removePaidItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;
    
    if (_isAuthenticated) {
      // Đã đăng nhập, xóa từ server
      await _cartManager.removeMultipleItems(itemIds);
    } else {
      // Chưa đăng nhập, xóa từ local
      await _removeMultipleItemsFromLocalCart(itemIds);
    }
    
    // Also clear these items from the selected items set
    for (final id in itemIds) {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      }
    }
    notifyListeners();
  }
  
  // Xóa nhiều sản phẩm khỏi giỏ hàng local
  Future<void> _removeMultipleItemsFromLocalCart(List<String> itemIds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> localCart = prefs.getStringList('local_cart') ?? [];
    
    List<CartItemModel> cartItems = localCart
        .map((itemJson) => CartItemModel.fromJson(json.decode(itemJson)))
        .toList();
    
    // Lọc bỏ các sản phẩm cần xóa
    cartItems = cartItems.where((item) => !itemIds.contains(item.id)).toList();
    
    // Lưu lại giỏ hàng
    localCart = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('local_cart', localCart);
    
    // Cập nhật giỏ hàng trong memory
    _cartManager.setItems(cartItems);
  }

  @override
  void dispose() {
    _cartManager.detach(_badgeObserver);
    _cartManager.detach(_totalObserver);
    super.dispose();
  }
}
