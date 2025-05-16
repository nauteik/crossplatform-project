import 'package:flutter/material.dart';
import '../../../data/model/order_model.dart';
import '../../../data/respository/order_repository.dart';
import '../models/payment_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

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
  String _selectedPaymentMethod = 'COD';
  List<String> _availablePaymentMethods = ['COD'];
  Map<String, dynamic>? _currentOrder;
  String _errorMessage = '';
  Map<String, dynamic>? _guestUserInfo;
  Map<String, dynamic>? _guestAddressInfo;
  String? _newUserToken;
  String? _newUserId;
  Map<String, String> _creditCardData = {
    'cardNumber': '',
    'cardHolderName': '',
    'expiryDate': '',
    'cvv': '',
  };
  Map<String, String> _bankTransferData = {
    'bankName': '',
    'accountNumber': '',
    'transferCode': '',
  };
  Map<String, String> _momoPaymentData = {
    'phoneNumber': '',
    'transactionId': '',
  };
  String _shippingAddress = '';
  List<String> _selectedItemIds = [];
  
  // Getters
  PaymentProcessState get state => _state;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  List<String> get availablePaymentMethods => _availablePaymentMethods;
  Map<String, dynamic>? get currentOrder => _currentOrder;
  String get errorMessage => _errorMessage;
  String? get newUserToken => _newUserToken;
  String? get newUserId => _newUserId;
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
    _selectedItemIds = List.from(itemIds);
  }
  
  void setGuestCheckoutInfo(Map<String, dynamic> userInfo, Map<String, dynamic> addressInfo) {
    _guestUserInfo = userInfo;
    _guestAddressInfo = addressInfo;
  }
  
  void updateCreditCardData({
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
  }) {
    if (cardNumber != null) _creditCardData['cardNumber'] = cardNumber;
    if (cardHolderName != null) _creditCardData['cardHolderName'] = cardHolderName;
    if (expiryDate != null) _creditCardData['expiryDate'] = expiryDate;
    if (cvv != null) _creditCardData['cvv'] = cvv;
  }
  
  void updateBankTransferData({
    String? bankName,
    String? accountNumber,
    String? transferCode,
  }) {
    if (bankName != null) _bankTransferData['bankName'] = bankName;
    if (accountNumber != null) _bankTransferData['accountNumber'] = accountNumber;
    if (transferCode != null) _bankTransferData['transferCode'] = transferCode;
  }
  
  void updateMomoPaymentData({
    String? phoneNumber,
    String? transactionId,
  }) {
    if (phoneNumber != null) _momoPaymentData['phoneNumber'] = phoneNumber;
    if (transactionId != null) _momoPaymentData['transactionId'] = transactionId;
  }
  
  void reset() {
    _state = PaymentProcessState.initial;
    _selectedPaymentMethod = 'COD';
    _currentOrder = null;
    _errorMessage = '';
    _guestUserInfo = null;
    _guestAddressInfo = null;
    _newUserToken = null;
    _newUserId = null;
    _creditCardData = {
      'cardNumber': '',
      'cardHolderName': '',
      'expiryDate': '',
      'cvv': '',
    };
    _bankTransferData = {
      'bankName': '',
      'accountNumber': '',
      'transferCode': '',
    };
    _momoPaymentData = {
      'phoneNumber': '',
      'transactionId': '',
    };
    _shippingAddress = '';
    _selectedItemIds = [];
    notifyListeners();
  }
  
  Future<void> loadPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/orders/payment-methods'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _availablePaymentMethods = List<String>.from(jsonData['data']);
          
          if (_availablePaymentMethods.contains('COD')) {
            _selectedPaymentMethod = 'COD';
          } else if (_availablePaymentMethods.isNotEmpty) {
            _selectedPaymentMethod = _availablePaymentMethods[0];
          }
          
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading payment methods: $e');
    }
  }
  
  Future<bool> createOrder(String userId) async {
    try {
      Map<String, dynamic> orderData = {
        'userId': userId,
        'paymentMethod': _selectedPaymentMethod,
        'selectedItemIds': _selectedItemIds,
      };
      
      if (_shippingAddress.isNotEmpty) {
        orderData['shippingAddress'] = _shippingAddress;
      }
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _currentOrder = jsonData['data']['order'];
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Unknown error';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Error creating order: $e';
      return false;
    }
  }
  
  Future<bool> createGuestOrder() async {
    if (_guestUserInfo == null || _guestAddressInfo == null) {
      _errorMessage = 'Missing guest information';
      return false;
    }
    
    try {
      Map<String, dynamic> orderData = {
        'paymentMethod': _selectedPaymentMethod,
        'selectedItemIds': _selectedItemIds,
        'userInfo': _guestUserInfo,
        'addressInfo': _guestAddressInfo,
      };
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _currentOrder = jsonData['data']['order'];
          
          if (jsonData['data']['token'] != null) {
            _newUserToken = jsonData['data']['token'];
          }
          
          if (jsonData['data']['userId'] != null) {
            _newUserId = jsonData['data']['userId'];
          }
          
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Unknown error';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Error creating order: $e';
      return false;
    }
  }
  
  Future<bool> processPayment() async {
    if (_currentOrder == null) {
      _errorMessage = 'No active order to process';
      return false;
    }
    
    try {
      String orderId = _currentOrder!['id'];
      
      Map<String, dynamic> paymentData = {};
      
      switch (_selectedPaymentMethod) {
        case 'CREDIT_CARD':
          paymentData = {..._creditCardData};
          break;
        case 'BANK_TRANSFER':
          paymentData = {..._bankTransferData};
          break;
        case 'MOMO':
          paymentData = {..._momoPaymentData};
          break;
        case 'COD':
          paymentData = {'confirmed': true};
          break;
      }
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/pay'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentData),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200) {
          _currentOrder = jsonData['data'];
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Payment processing failed';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Error processing payment: $e';
      return false;
    }
  }
  
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