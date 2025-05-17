import 'package:flutter/material.dart';

class PaymentRequest {
  final String userId;
  final String paymentMethod;
  final List<String> selectedItemIds;
  final Map<String, dynamic>? addressMap;
  final String? addressId;
  final String? couponCode;
  final Map<String, dynamic>? paymentDetails;

  PaymentRequest({
    required this.userId,
    required this.paymentMethod,
    required this.selectedItemIds,
    this.addressMap,
    this.addressId,
    this.couponCode,
    this.paymentDetails,
  });

  // Factory method to create a Credit Card payment request
  factory PaymentRequest.creditCard({
    required String userId,
    required List<String> selectedItemIds,
    required String cardNumber,
    required String cardName,
    required String expiryDate,
    required String cvv,
    Map<String, dynamic>? addressMap,
    String? addressId,
    String? couponCode,
  }) {
    return PaymentRequest(
      userId: userId,
      selectedItemIds: selectedItemIds,
      paymentMethod: 'CREDIT_CARD',
      addressMap: addressMap,
      addressId: addressId,
      couponCode: couponCode,
      paymentDetails: {
        'cardNumber': cardNumber,
        'cardName': cardName,
        'expiryDate': expiryDate,
        'cvv': cvv,
      },
    );
  }

  // Factory method to create a Cash on Delivery payment request
  factory PaymentRequest.cod({
    required String userId,
    required List<String> selectedItemIds,
    Map<String, dynamic>? addressMap,
    String? addressId,
    String? couponCode,
    String? deliveryNotes,
  }) {
    return PaymentRequest(
      userId: userId,
      selectedItemIds: selectedItemIds,
      paymentMethod: 'COD',
      addressMap: addressMap,
      addressId: addressId,
      couponCode: couponCode,
      paymentDetails: {
        'deliveryNotes': deliveryNotes ?? '',
      },
    );
  }
  
  // Factory method to create a Bank Transfer payment request
  factory PaymentRequest.bankTransfer({
    required String userId,
    required List<String> selectedItemIds,
    required String accountNumber,
    required String bankName,
    Map<String, dynamic>? addressMap,
    String? addressId,
    String? couponCode,
    String? transferCode,
  }) {
    return PaymentRequest(
      userId: userId,
      selectedItemIds: selectedItemIds,
      paymentMethod: 'BANK_TRANSFER',
      addressMap: addressMap,
      addressId: addressId,
      couponCode: couponCode,
      paymentDetails: {
        'accountNumber': accountNumber,
        'bankName': bankName,
        'transferCode': transferCode ?? '',
      },
    );
  }
  
  // Factory method to create a MoMo payment request
  factory PaymentRequest.momo({
    required String userId,
    required List<String> selectedItemIds,
    required String phoneNumber,
    Map<String, dynamic>? addressMap,
    String? addressId,
    String? couponCode,
    String? transactionId,
  }) {
    return PaymentRequest(
      userId: userId,
      selectedItemIds: selectedItemIds,
      paymentMethod: 'MOMO',
      addressMap: addressMap,
      addressId: addressId,
      couponCode: couponCode,
      paymentDetails: {
        'phoneNumber': phoneNumber,
        'transactionId': transactionId ?? '',
      },
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'paymentMethod': paymentMethod,
      'selectedItemIds': selectedItemIds,
    };

    if (addressMap != null) {
      data['shippingAddress'] = addressMap;
    }

    if (addressId != null) {
      data['addressId'] = addressId;
    }
    
    if (couponCode != null && couponCode!.isNotEmpty) {
      data['couponCode'] = couponCode;
    }
    
    if (paymentDetails != null) {
      data.addAll(paymentDetails!);
    }

    return data;
  }
}

class GuestPaymentRequest {
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> addressInfo;
  final String paymentMethod;
  final List<String> selectedItemIds;
  final String? couponCode;

  GuestPaymentRequest({
    required this.userInfo,
    required this.addressInfo,
    required this.paymentMethod,
    required this.selectedItemIds,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userInfo': userInfo,
      'addressInfo': addressInfo,
      'paymentMethod': paymentMethod,
      'selectedItemIds': selectedItemIds,
    };
    
    if (couponCode != null && couponCode!.isNotEmpty) {
      data['couponCode'] = couponCode;
    }

    return data;
  }
}

// Model for Credit Card data validation and form handling
class CreditCardModel {
  String cardNumber;
  String cardHolderName;
  String expiryDate;
  String cvv;
  bool isValid;

  CreditCardModel({
    this.cardNumber = '',
    this.cardHolderName = '',
    this.expiryDate = '',
    this.cvv = '',
    this.isValid = false,
  });

  // Simple validation logic
  void validate() {
    // Simple validation - in a real app, you would use more robust validation
    bool hasValidCardNumber = cardNumber.length >= 13 && cardNumber.length <= 19;
    bool hasValidName = cardHolderName.isNotEmpty;
    bool hasValidExpiry = expiryDate.length == 5 && expiryDate.contains('/');
    bool hasValidCvv = cvv.length >= 3 && cvv.length <= 4;
    
    isValid = hasValidCardNumber && hasValidName && hasValidExpiry && hasValidCvv;
  }
}

// Model for Bank Transfer data validation and form handling
class BankTransferModel {
  String accountNumber;
  String bankName;
  String transferCode;
  bool isValid;
  
  BankTransferModel({
    this.accountNumber = '',
    this.bankName = '',
    this.transferCode = '',
    this.isValid = false,
  });
  
  // Simple validation logic
  void validate() {
    bool hasValidAccountNumber = accountNumber.length >= 10;
    bool hasValidBankName = bankName.isNotEmpty;
    
    isValid = hasValidAccountNumber && hasValidBankName;
  }
}

// Model for MoMo payment data validation and form handling
class MomoPaymentModel {
  String phoneNumber;
  String transactionId;
  bool isValid;
  
  MomoPaymentModel({
    this.phoneNumber = '',
    this.transactionId = '',
    this.isValid = false,
  });
  
  // Simple validation logic
  void validate() {
    // Phone number should be a valid Vietnamese phone number format
    bool hasValidPhoneNumber = phoneNumber.length == 10;
    
    isValid = hasValidPhoneNumber;
  }
}