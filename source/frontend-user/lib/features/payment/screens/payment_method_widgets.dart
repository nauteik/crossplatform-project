import 'package:flutter/material.dart';
import '../providers/payment_provider.dart';

/// Class chứa các widget phương thức thanh toán tái sử dụng
class PaymentMethodWidgets {
  
  /// Widget hiển thị danh sách phương thức thanh toán
  static Widget buildPaymentMethodSelection(
    PaymentProvider paymentProvider,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức thanh toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...paymentProvider.availablePaymentMethods.map(
          (method) => RadioListTile<String>(
            title: Text(formatPaymentMethodName(method)),
            value: method,
            groupValue: paymentProvider.selectedPaymentMethod,
            onChanged: (value) {
              if (value != null) {
                paymentProvider.setSelectedPaymentMethod(value);
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ).toList(),
      ],
    );
  }

  /// Format tên phương thức thanh toán
  static String formatPaymentMethodName(String method) {
    switch (method) {
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản ngân hàng';
      case 'MOMO':
        return 'MoMo E-Wallet';
      default:
        return method;
    }
  }

  /// Widget hiển thị form thanh toán thẻ tín dụng
  static Widget buildCreditCardForm(
    PaymentProvider paymentProvider,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết thẻ tín dụng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Card Number
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Số thẻ',
            hintText: 'XXXX XXXX XXXX XXXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số thẻ';
            }
            if (value.length < 13 || value.length > 19) {
              return 'Số thẻ phải có từ 13-19 chữ số';
            }
            return null;
          },
          onChanged: (value) {
            paymentProvider.updateCreditCardData(cardNumber: value);
          },
        ),
        const SizedBox(height: 16),
        // Card Holder Name
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tên chủ thẻ',
            hintText: 'Tên trên thẻ',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên chủ thẻ';
            }
            return null;
          },
          onChanged: (value) {
            paymentProvider.updateCreditCardData(cardHolderName: value);
          },
        ),
        const SizedBox(height: 16),
        // Row for Expiry Date and CVV
        Row(
          children: [
            // Expiry Date
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ngày hết hạn',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập ngày hết hạn';
                  }
                  if (!value.contains('/') || value.length != 5) {
                    return 'Sử dụng định dạng MM/YY';
                  }
                  return null;
                },
                onChanged: (value) {
                  paymentProvider.updateCreditCardData(expiryDate: value);
                },
              ),
            ),
            const SizedBox(width: 16),
            // CVV
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập CVV';
                  }
                  if (value.length < 3) {
                    return 'CVV không hợp lệ';
                  }
                  return null;
                },
                onChanged: (value) {
                  paymentProvider.updateCreditCardData(cvv: value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget hiển thị form thanh toán chuyển khoản ngân hàng
  static Widget buildBankTransferForm(
    PaymentProvider paymentProvider,
    BuildContext context,
    double totalAmount,
  ) {
    // List of common Vietnamese banks
    final banks = [
      'Vietcombank',
      'BIDV',
      'Agribank',
      'Techcombank',
      'VPBank',
      'MB Bank',
      'ACB',
      'Sacombank',
      'TPBank',
      'VIB',
      'Other'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết chuyển khoản ngân hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Bank name dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Tên ngân hàng',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: banks.map((bank) => DropdownMenuItem<String>(
            value: bank,
            child: Text(bank),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              paymentProvider.updateBankTransferData(bankName: value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn ngân hàng của bạn';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Account number
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Số tài khoản',
            hintText: 'Nhập số tài khoản ngân hàng của bạn',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_box),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số tài khoản';
            }
            if (value.length < 10) {
              return 'Số tài khoản phải có ít nhất 10 chữ số';
            }
            return null;
          },
          onChanged: (value) {
            paymentProvider.updateBankTransferData(accountNumber: value);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Transfer instructions
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Hướng dẫn chuyển khoản',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('1. Chuyển đúng số tiền đến tài khoản của chúng tôi.'),
                const Text('2. Sử dụng ID đơn hàng làm tham chiếu.'),
                const Text('3. Đơn hàng của bạn sẽ được xử lý sau khi xác nhận thanh toán.'),
                const SizedBox(height: 8),
                Text('Số tiền chuyển: ${formatCurrency(totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Tên tài khoản: Cửa hàng E-commerce JSC',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Số tài khoản: 12345678900',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Ngân hàng: Vietcombank',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị form thanh toán bằng ví điện tử Momo
  static Widget buildMomoPaymentForm(
    PaymentProvider paymentProvider,
    BuildContext context,
    double totalAmount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thanh toán MoMo E-Wallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Phone number linked to MoMo account
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Số điện thoại MoMo',
            hintText: 'Nhập số điện thoại MoMo đã liên kết',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số điện thoại MoMo của bạn';
            }
            if (value.length != 10) {
              return 'Số điện thoại phải có 10 chữ số';
            }
            return null;
          },
          onChanged: (value) {
            paymentProvider.updateMomoPaymentData(phoneNumber: value);
          },
        ),
        
        const SizedBox(height: 16),
        
        // MoMo payment instructions with QR code mock
        Card(
          color: Colors.pink[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.pink[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Hướng dẫn thanh toán MoMo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('1. Mở ứng dụng MoMo.'),
                const Text('2. Quét mã QR code bên dưới.'),
                const Text('3. Nhập đúng số tiền và ID đơn hàng làm tham chiếu.'),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.pink.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code,
                        size: 120,
                        color: Colors.pink[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Số tiền chuyển: ${formatCurrency(totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Số điện thoại MoMo: 0987654321',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị form thanh toán tiền mặt khi nhận hàng
  static Widget buildCodForm(
    BuildContext context,
    double totalAmount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thanh toán tiền mặt',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Thông tin thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Bạn sẽ thanh toán tiền mặt cho người giao hàng khi đơn hàng đến.'),
                const SizedBox(height: 8),
                Text('Số tiền thanh toán: ${formatCurrency(totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Đảm bảo có đủ tiền mặt nếu có thể.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Ghi chú giao hàng (Tùy chọn)',
            hintText: 'Các hướng dẫn đặc biệt cho giao hàng',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
  
  /// Format số tiền thành chuỗi tiền tệ Việt Nam
  static String formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }
} 