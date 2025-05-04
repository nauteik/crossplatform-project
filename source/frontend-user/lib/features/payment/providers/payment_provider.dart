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
  List<String> _availablePaymentMethods = ['CREDIT_CARD', 'COD', 'BANK_TRANSFER', 'MOMO']; // Default options with new methods
  OrderModel? _currentOrder;
  String _errorMessage = '';
  CreditCardModel _creditCardData = CreditCardModel();
  BankTransferModel _bankTransferData = BankTransferModel(); // New model for bank transfers
  MomoPaymentModel _momoPaymentData = MomoPaymentModel(); // New model for MoMo payments
  String _shippingAddress = '';
  List<String> _selectedItemIds = []; // Field to store selected item IDs
  
  // Getters
  PaymentProcessState get state => _state;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  List<String> get availablePaymentMethods => _availablePaymentMethods;
  OrderModel? get currentOrder => _currentOrder;
  String get errorMessage => _errorMessage;
  CreditCardModel get creditCardData => _creditCardData;
  BankTransferModel get bankTransferData => _bankTransferData; // Getter for bank transfer data
  MomoPaymentModel get momoPaymentData => _momoPaymentData; // Getter for MoMo payment data
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
  
  // New method to update bank transfer data
  void updateBankTransferData({
    String? accountNumber,
    String? bankName,
    String? transferCode,
  }) {
    if (accountNumber != null) _bankTransferData.accountNumber = accountNumber;
    if (bankName != null) _bankTransferData.bankName = bankName;
    if (transferCode != null) _bankTransferData.transferCode = transferCode;
    
    _bankTransferData.validate();
    notifyListeners();
  }
  
  // New method to update MoMo payment data
  void updateMomoPaymentData({
    String? phoneNumber,
    String? transactionId,
  }) {
    if (phoneNumber != null) _momoPaymentData.phoneNumber = phoneNumber;
    if (transactionId != null) _momoPaymentData.transactionId = transactionId;
    
    _momoPaymentData.validate();
    notifyListeners();
  }
  
  // Load available payment methods from the API
  Future<void> loadPaymentMethods() async {
    try {
      final response = await _orderRepository.getSupportedPaymentMethods();
      _availablePaymentMethods = response.data ?? ['CREDIT_CARD', 'COD', 'BANK_TRANSFER', 'MOMO'];
      
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
    _bankTransferData = BankTransferModel(); // Reset bank transfer data
    _momoPaymentData = MomoPaymentModel(); // Reset MoMo payment data
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
        selectedItemIds: _selectedItemIds,
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
      
      switch (_selectedPaymentMethod) {
        case 'CREDIT_CARD':
          // Validate credit card data
          _creditCardData.validate();
          if (!_creditCardData.isValid) {
            _errorMessage = 'Invalid credit card information';
            _state = PaymentProcessState.orderCreated;
            notifyListeners();
            return false;
          }
          
          paymentRequest = PaymentRequest.creditCard(
            cardNumber: _creditCardData.cardNumber,
            cardName: _creditCardData.cardHolderName,
            expiryDate: _creditCardData.expiryDate,
            cvv: _creditCardData.cvv,
          );
          break;
          
        case 'BANK_TRANSFER':
          // Validate bank transfer data
          _bankTransferData.validate();
          if (!_bankTransferData.isValid) {
            _errorMessage = 'Invalid bank transfer information';
            _state = PaymentProcessState.orderCreated;
            notifyListeners();
            return false;
          }
          
          paymentRequest = PaymentRequest.bankTransfer(
            accountNumber: _bankTransferData.accountNumber,
            bankName: _bankTransferData.bankName,
            transferCode: _bankTransferData.transferCode,
          );
          break;
          
        case 'MOMO':
          // Validate MoMo payment data
          _momoPaymentData.validate();
          if (!_momoPaymentData.isValid) {
            _errorMessage = 'Invalid MoMo payment information';
            _state = PaymentProcessState.orderCreated;
            notifyListeners();
            return false;
          }
          
          paymentRequest = PaymentRequest.momo(
            phoneNumber: _momoPaymentData.phoneNumber,
            transactionId: _momoPaymentData.transactionId,
          );
          break;
          
        case 'COD':
          paymentRequest = PaymentRequest.cod();
          break;
          
        default:
          throw Exception('Unsupported payment method: $_selectedPaymentMethod');
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