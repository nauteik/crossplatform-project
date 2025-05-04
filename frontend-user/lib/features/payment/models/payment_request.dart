class PaymentRequest {
  final String paymentMethod;
  final Map<String, dynamic> paymentDetails;

  PaymentRequest({
    required this.paymentMethod,
    required this.paymentDetails,
  });

  // Factory method to create a Credit Card payment request
  factory PaymentRequest.creditCard({
    required String cardNumber,
    required String cardName,
    required String expiryDate,
    required String cvv,
  }) {
    return PaymentRequest(
      paymentMethod: 'CREDIT_CARD',
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
    String? deliveryNotes,
  }) {
    return PaymentRequest(
      paymentMethod: 'COD',
      paymentDetails: {
        'deliveryNotes': deliveryNotes ?? '',
      },
    );
  }
  
  // Factory method to create a Bank Transfer payment request
  factory PaymentRequest.bankTransfer({
    required String accountNumber,
    required String bankName,
    String? transferCode,
  }) {
    return PaymentRequest(
      paymentMethod: 'BANK_TRANSFER',
      paymentDetails: {
        'accountNumber': accountNumber,
        'bankName': bankName,
        'transferCode': transferCode ?? '',
      },
    );
  }
  
  // Factory method to create a MoMo payment request
  factory PaymentRequest.momo({
    required String phoneNumber,
    String? transactionId,
  }) {
    return PaymentRequest(
      paymentMethod: 'MOMO',
      paymentDetails: {
        'phoneNumber': phoneNumber,
        'transactionId': transactionId ?? '',
      },
    );
  }

  Map<String, dynamic> toJson() {
    return paymentDetails;
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