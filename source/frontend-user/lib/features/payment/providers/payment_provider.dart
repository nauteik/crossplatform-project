import 'package:flutter/material.dart';
import '../../../core/models/address_model.dart';
import '../../../data/model/order_model.dart';
import '../../../data/respository/order_repository.dart';
import '../models/payment_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
  String? _newUsername;
  String? _newPassword;
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
  AddressModel? _selectedAddress;
  String _manualShippingAddress = '';
  List<String> _selectedItemIds = [];
  
  // Coupon fields
  String _couponCode = '';
  Map<String, dynamic>? _couponDetails;
  bool _isCouponValid = false;
  bool _isCheckingCoupon = false;
  
  // Loyalty Points fields
  int _userLoyaltyPoints = 0;
  int _loyaltyPointsToUse = 0;
  double _loyaltyPointsDiscount = 0.0;
  bool _isLoadingLoyaltyPoints = false;
  
  // Getters
  PaymentProcessState get state => _state;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  List<String> get availablePaymentMethods => _availablePaymentMethods;
  Map<String, dynamic>? get currentOrder => _currentOrder;
  String get errorMessage => _errorMessage;
  String? get newUserToken => _newUserToken;
  String? get newUserId => _newUserId;
  String? get newUsername => _newUsername;
  String? get newPassword => _newPassword;
  bool get isLoading => _state == PaymentProcessState.creatingOrder || 
                        _state == PaymentProcessState.processing;
  String get couponCode => _couponCode;
  Map<String, dynamic>? get couponDetails => _couponDetails;
  bool get isCouponValid => _isCouponValid;
  bool get isCheckingCoupon => _isCheckingCoupon;
  
  // Loyalty Points getters
  int get userLoyaltyPoints => _userLoyaltyPoints;
  int get loyaltyPointsToUse => _loyaltyPointsToUse;
  double get loyaltyPointsDiscount => _loyaltyPointsDiscount;
  bool get isLoadingLoyaltyPoints => _isLoadingLoyaltyPoints;
  
  // Setters
  void setSelectedAddress(AddressModel address) {
    _selectedAddress = address;
    _manualShippingAddress = '';
    notifyListeners();
  }
  
  void setShippingAddress(String address) {
    _manualShippingAddress = address;
    _selectedAddress = null;
    notifyListeners();
  }
  
  void setSelectedPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }
  
  void setSelectedItemIds(List<String> itemIds) {
    _selectedItemIds = List.from(itemIds);
  }
  
  void setCouponCode(String code) {
    _couponCode = code;
    if (code.isEmpty) {
      _couponDetails = null;
      _isCouponValid = false;
    }
    notifyListeners();
  }
  
  void setLoyaltyPointsToUse(int points) {
    if (points < 0) points = 0;
    if (points > _userLoyaltyPoints) points = _userLoyaltyPoints;
    
    _loyaltyPointsToUse = points;
    // Mỗi điểm tương đương 1,000 VND
    _loyaltyPointsDiscount = points * 1000;
    notifyListeners();
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
    _newUsername = null;
    _newPassword = null;
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
    _selectedAddress = null;
    _manualShippingAddress = '';
    _selectedItemIds = [];
    _couponCode = '';
    _couponDetails = null;
    _isCouponValid = false;
    _userLoyaltyPoints = 0;
    _loyaltyPointsToUse = 0;
    _loyaltyPointsDiscount = 0.0;
    notifyListeners();
  }
  
  // Lấy số điểm tích lũy của người dùng
  Future<void> loadUserLoyaltyPoints(String userId, String? token) async {
    if (token == null) return;
    
    _isLoadingLoyaltyPoints = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/orders/user/$userId/loyalty-points'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _userLoyaltyPoints = jsonData['data']['loyaltyPoints'] ?? 0;
        } else {
          _userLoyaltyPoints = 0;
        }
      } else {
        _userLoyaltyPoints = 0;
      }
    } catch (e) {
      print('Error loading loyalty points: $e');
      _userLoyaltyPoints = 0;
    } finally {
      _isLoadingLoyaltyPoints = false;
      notifyListeners();
    }
  }
  
  // Kiểm tra coupon
  Future<bool> checkCoupon(String code) async {
    if (code.isEmpty) {
      return false;
    }
    
    _isCheckingCoupon = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/coupons/check/$code'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _couponDetails = jsonData['data'];
          _isCouponValid = _couponDetails!['valid'] == true;
          _couponCode = code;
          _isCheckingCoupon = false;
          notifyListeners();
          return _isCouponValid;
        } else {
          _errorMessage = jsonData['message'] ?? 'Mã giảm giá không hợp lệ';
          _isCheckingCoupon = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Lỗi kết nối khi kiểm tra mã giảm giá';
        _isCheckingCoupon = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _isCheckingCoupon = false;
      notifyListeners();
      return false;
    }
  }
  
  // Áp dụng coupon cho đơn hàng đã tạo
  Future<bool> applyCouponToOrder(String orderId, String code) async {
    if (code.isEmpty) {
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/apply-coupon'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'couponCode': code}),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _currentOrder = jsonData['data'];
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Không thể áp dụng coupon';
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Lỗi server: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi áp dụng coupon: $e';
      notifyListeners();
      return false;
    }
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
    _state = PaymentProcessState.creatingOrder;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Validate required fields
      if (_selectedPaymentMethod.isEmpty) {
        _errorMessage = 'Vui lòng chọn phương thức thanh toán';
        _state = PaymentProcessState.failed;
        notifyListeners();
        return false;
      }
      
      if (_selectedAddress == null) {
        _errorMessage = 'Vui lòng chọn địa chỉ giao hàng';
        _state = PaymentProcessState.failed;
        notifyListeners();
        return false;
      }
      
      // Prepare request data
      Map<String, dynamic> orderData = {
        'userId': userId,
        'paymentMethod': _selectedPaymentMethod,
        'selectedItemIds': _selectedItemIds,
      };
      
      // Add address information
      if (_selectedAddress != null) {
        orderData['addressId'] = _selectedAddress!.id;
      }
      
      // Add coupon code if available
      if (_isCouponValid && _couponCode.isNotEmpty) {
        orderData['couponCode'] = _couponCode;
      }
      
      // Add loyalty points if using
      if (_loyaltyPointsToUse > 0) {
        orderData['loyaltyPointsToUse'] = _loyaltyPointsToUse;
      }
      
      // Create order
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/user/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _currentOrder = jsonData['data'];
          _state = PaymentProcessState.orderCreated;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Lỗi khi tạo đơn hàng';
          _state = PaymentProcessState.failed;
          notifyListeners();
          return false;
        }
      } else {
        final jsonData = json.decode(response.body);
        _errorMessage = jsonData['message'] ?? 'Lỗi kết nối khi tạo đơn hàng';
        _state = PaymentProcessState.failed;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      _state = PaymentProcessState.failed;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> createGuestOrder(BuildContext context) async {
    _state = PaymentProcessState.creatingOrder;
    notifyListeners();
    
    if (_guestUserInfo == null || _guestAddressInfo == null) {
      _errorMessage = 'Missing guest information';
      _state = PaymentProcessState.failed;
      notifyListeners();
      return false;
    }
    
    try {
      Map<String, dynamic> orderData = {
        'paymentMethod': _selectedPaymentMethod,
        'selectedItemIds': _selectedItemIds,
        'userInfo': _guestUserInfo,
        'addressInfo': _guestAddressInfo,
      };
      
      // Thêm coupon nếu có
      if (_couponCode.isNotEmpty && _isCouponValid) {
        orderData['couponCode'] = _couponCode;
      }
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders/guest/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 200 && jsonData['data'] != null) {
          _currentOrder = jsonData['data']['order'];
          
          if (jsonData['data']['userId'] != null) {
            _newUserId = jsonData['data']['userId'];
          }
          
          if (jsonData['data']['username'] != null) {
            _newUsername = jsonData['data']['username'];
          }
          
          if (jsonData['data']['password'] != null) {
            _newPassword = jsonData['data']['password'];
          }
          
          // Đăng nhập tự động nếu có username và password
          if (_newUsername != null && _newPassword != null) {
            await loginGuestWithCredentials(context, _newUsername!, _newPassword!);
          }
          
          _state = PaymentProcessState.orderCreated;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Unknown error';
          _state = PaymentProcessState.failed;
          notifyListeners();
        }
      } else {
        final errorJson = json.decode(response.body);
        _errorMessage = errorJson['message'] ?? 'Server error: ${response.statusCode}';
        _state = PaymentProcessState.failed;
        notifyListeners();
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Error creating order: $e';
      _state = PaymentProcessState.failed;
      notifyListeners();
      return false;
    }
  }
  
  // Phương thức đăng nhập tự động cho guest user
  Future<void> loginGuestWithCredentials(BuildContext context, String username, String password) async {
    try {
      // Lấy AuthProvider từ context
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Sử dụng phương thức login từ AuthProvider để đảm bảo logic xử lý đăng nhập thống nhất
      bool success = await authProvider.login(username, password, context);
      
      if (success) {
        print('Đăng nhập tự động thành công với username: $username');
      } else {
        print('Đăng nhập tự động thất bại: ${authProvider.errorMessage}');
      }
    } catch (e) {
      print('Lỗi khi đăng nhập tự động: $e');
    }
  }
  
  Future<bool> processPayment() async {
    if (_currentOrder == null) {
      _errorMessage = 'No active order to process';
      return false;
    }
    
    _state = PaymentProcessState.processing;
    notifyListeners();
    
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
          _state = PaymentProcessState.success;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Payment processing failed';
          _state = PaymentProcessState.failed;
          notifyListeners();
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _state = PaymentProcessState.failed;
        notifyListeners();
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Error processing payment: $e';
      _state = PaymentProcessState.failed;
      notifyListeners();
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