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