import 'package:flutter/material.dart';
import '../../../data/model/order_model.dart';
import '../../../data/respository/order_repository.dart';
import '../models/payment_request.dart';

enum PaymentProcessState {
  initial,
  creatingOrder,
  orderCreated,
  processing,
  success,
  failed,
}

class PaymentProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  
  PaymentProcessState _state = PaymentProcessState.initial;
  String _selectedPaymentMethod = 'CREDIT_CARD'; // Default selection
  List<String> _availablePaymentMethods = ['CREDIT_CARD', 'COD']; // Default options
  OrderModel? _currentOrder;
  String _errorMessage = '';
  CreditCardModel _creditCardData = CreditCardModel();
  String _shippingAddress = '';
  List<String> _selectedItemIds = []; // New field to store selected item IDs
  
  // Getters
  PaymentProcessState get state => _state;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  List<String> get availablePaymentMethods => _availablePaymentMethods;
  OrderModel? get currentOrder => _currentOrder;
  String get errorMessage => _errorMessage;
  CreditCardModel get creditCardData => _creditCardData;
  String get shippingAddress => _shippingAddress;
  List<String> get selectedItemIds => _selectedItemIds;
  bool get isLoading => _state == PaymentProcessState.creatingOrder || 
                        _state == PaymentProcessState.processing;
  
  // Setters
  void setShippingAddress(String address) {
    _shippingAddress = address;
    notifyListeners();
  }
  
  void setSelectedPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }
  
  void setSelectedItemIds(List<String> itemIds) {
    _selectedItemIds = itemIds;
  }
  
  void updateCreditCardData({
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
  }) {
    if (cardNumber != null) _creditCardData.cardNumber = cardNumber;
    if (cardHolderName != null) _creditCardData.cardHolderName = cardHolderName;
    if (expiryDate != null) _creditCardData.expiryDate = expiryDate;
    if (cvv != null) _creditCardData.cvv = cvv;
    
    _creditCardData.validate();
    notifyListeners();
  }
  
  // Load available payment methods from the API
  Future<void> loadPaymentMethods() async {
    try {
      final response = await _orderRepository.getSupportedPaymentMethods();
      _availablePaymentMethods = response.data ?? ['CREDIT_CARD', 'COD'];
      
      // Default to first available method if current selection is not available
      if (!_availablePaymentMethods.contains(_selectedPaymentMethod) && 
          _availablePaymentMethods.isNotEmpty) {
        _selectedPaymentMethod = _availablePaymentMethods.first;
      }
      
      notifyListeners();
    } catch (e) {
      // If API fails, use default values
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Reset the payment process
  void reset() {
    _state = PaymentProcessState.initial;
    _currentOrder = null;
    _errorMessage = '';
    _creditCardData = CreditCardModel();
    _selectedItemIds = []; // Reset selected items
    notifyListeners();
  }
  
  // Start checkout process - create order
  Future<bool> createOrder(String userId) async {
    if (_shippingAddress.isEmpty) {
      _errorMessage = 'Please enter a shipping address';
      notifyListeners();
      return false;
    }
    
    if (_selectedItemIds.isEmpty) {
      _errorMessage = 'No items selected for checkout';
      notifyListeners();
      return false;
    }
    
    try {
      _state = PaymentProcessState.creatingOrder;
      _errorMessage = '';
      notifyListeners();
      
      final response = await _orderRepository.createOrder(
        userId: userId,
        shippingAddress: _shippingAddress,
        paymentMethod: _selectedPaymentMethod,
        selectedItemIds: _selectedItemIds, // Pass selected item IDs
      );
      
      _currentOrder = response.data;
      _state = PaymentProcessState.orderCreated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = PaymentProcessState.failed;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Process payment for the created order
  Future<bool> processPayment() async {
    if (_currentOrder == null) {
      _errorMessage = 'No order has been created yet';
      notifyListeners();
      return false;
    }
    
    try {
      _state = PaymentProcessState.processing;
      _errorMessage = '';
      notifyListeners();
      
      // Create payment request based on selected method
      PaymentRequest paymentRequest;
      
      if (_selectedPaymentMethod == 'CREDIT_CARD') {
        // Validate credit card data
        _creditCardData.validate();
        if (!_creditCardData.isValid) {
          _errorMessage = 'Invalid credit card information';
          _state = PaymentProcessState.orderCreated; // Back to order created state
          notifyListeners();
          return false;
        }
        
        paymentRequest = PaymentRequest.creditCard(
          cardNumber: _creditCardData.cardNumber,
          cardName: _creditCardData.cardHolderName,
          expiryDate: _creditCardData.expiryDate,
          cvv: _creditCardData.cvv,
        );
      } else if (_selectedPaymentMethod == 'COD') {
        paymentRequest = PaymentRequest.cod();
      } else {
        throw Exception('Unsupported payment method');
      }
      
      // Process payment
      final response = await _orderRepository.processPayment(
        orderId: _currentOrder!.id,
        paymentDetails: paymentRequest.paymentDetails,
      );
      
      _currentOrder = response.data;
      
      if (_currentOrder?.status.name == 'PAID') {
        _state = PaymentProcessState.success;
        notifyListeners();
        return true;
      } else {
        _state = PaymentProcessState.failed;
        _errorMessage = 'Payment failed';
        notifyListeners();
        return false;
      }
      
    } catch (e) {
      _state = PaymentProcessState.failed;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Fetch user's order history
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    try {
      final response = await _orderRepository.getOrdersByUser(userId);
      return response.data ?? [];
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
}