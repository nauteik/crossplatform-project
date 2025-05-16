import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/address_model.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/model/cart_item_model.dart';
import '../../../utils/route_transitions.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/data/repositories/address_provider.dart';
import '../models/payment_request.dart';
import '../providers/payment_provider.dart';
import 'order_confirmation_screen.dart';
import '../../../core/utils/image_helper.dart';
class CheckoutScreen extends StatefulWidget {
  final String userId;
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    Key? key,
    required this.userId,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Load available payment methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.loadPaymentMethods();
      
      // Set the selected item IDs in the payment provider
      final List<String> itemIds = widget.cartItems.map((item) => item.id).toList();
      paymentProvider.setSelectedItemIds(itemIds);
      
      // Load user addresses
      _loadUserAddresses();
    });
  }

  Future<void> _loadUserAddresses() async {
    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressProvider>();
    
    if (authProvider.isAuthenticated && authProvider.token != null) {
      await addressProvider.fetchUserAddresses(
        widget.userId,
        authProvider.token!,
      );
      
      // Set default address if available
      if (addressProvider.defaultAddress != null) {
        setState(() {
          _selectedAddress = addressProvider.defaultAddress;
          _addressController.text = _selectedAddress!.fullAddress;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final paymentProvider = context.read<PaymentProvider>();
    
    // Set shipping address from selected address or text input
    if (_selectedAddress != null) {
      paymentProvider.setShippingAddress(_selectedAddress!.fullAddress);
    } else {
      paymentProvider.setShippingAddress(_addressController.text);
    }
    
    // Step 1: Create Order
    final orderCreated = await paymentProvider.createOrder(widget.userId);
    
    if (!orderCreated) {
      setState(() => _isProcessing = false);
      _showErrorSnackbar(paymentProvider.errorMessage);
      return;
    }
    
    // Step 2: Process Payment
    final paymentSuccess = await paymentProvider.processPayment();
    
    setState(() => _isProcessing = false);
    
    if (paymentSuccess) {
      // Get cart provider to remove paid items
      final cartProvider = context.read<CartProvider>();
      
      // Get the list of paid item IDs
      final paidItemIds = widget.cartItems.map((item) => item.id).toList();
      
      // Remove the paid items from the cart
      await cartProvider.removePaidItems(paidItemIds);
      
      // Navigate to confirmation page using slide transition
      // Using pushReplacement to prevent going back to checkout
      Navigator.of(context).pushReplacement(
        SlideRightRoute(
          page: OrderConfirmationScreen(
            order: paymentProvider.currentOrder!,
          ),
        ),
      );
    } else {
      _showErrorSnackbar(paymentProvider.errorMessage);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Order Summary
                _buildOrderSummary(),
                
                const SizedBox(height: 24),
                
                // Shipping Address
                _buildShippingAddressSection(paymentProvider),
                
                const SizedBox(height: 24),
                
                // Payment Method Selection
                _buildPaymentMethodSelection(paymentProvider),
                
                const SizedBox(height: 24),
                
                // Conditional Payment Form based on selection
                if (paymentProvider.selectedPaymentMethod == 'CREDIT_CARD')
                  _buildCreditCardForm(paymentProvider)
                else if (paymentProvider.selectedPaymentMethod == 'BANK_TRANSFER')
                  _buildBankTransferForm(paymentProvider)
                else if (paymentProvider.selectedPaymentMethod == 'MOMO')
                  _buildMomoPaymentForm(paymentProvider)
                else if (paymentProvider.selectedPaymentMethod == 'COD')
                  _buildCodForm(),
                
                const SizedBox(height: 32),
                
                // Checkout Button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Place Order', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Here we're using the cartItems passed from the cart screen
            // These should only be the selected items
            ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      ImageHelper.getImage(item.imageUrl),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${item.quantity} x ${_formatCurrency(item.price)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(item.quantity * item.price),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(widget.totalAmount),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }

  Widget _buildShippingAddressSection(PaymentProvider paymentProvider) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Hiển thị địa chỉ đã chọn nếu có
            if (_selectedAddress != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedAddress!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: _selectAddress,
                            child: const Text('Thay đổi'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_selectedAddress!.phoneNumber),
                      const SizedBox(height: 4),
                      Text(_selectedAddress!.fullAddress),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Nhập địa chỉ mới nếu chưa có địa chỉ đã chọn
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your shipping address',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your shipping address';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      paymentProvider.setShippingAddress(value);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nút chọn địa chỉ từ danh sách đã lưu
                  OutlinedButton.icon(
                    onPressed: _selectAddress,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Chọn từ địa chỉ đã lưu'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _selectAddress() async {
    final address = await NavigationHelper.navigateToAddressSelection(context);
    if (address != null) {
      setState(() {
        _selectedAddress = address;
        _addressController.text = address.fullAddress;
      });
    }
  }

  Widget _buildPaymentMethodSelection(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...paymentProvider.availablePaymentMethods.map(
          (method) => RadioListTile<String>(
            title: Text(_formatPaymentMethodName(method)),
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

  String _formatPaymentMethodName(String method) {
    switch (method) {
      case 'CREDIT_CARD':
        return 'Credit Card';
      case 'COD':
        return 'Cash on Delivery';
      case 'BANK_TRANSFER':
        return 'Bank Transfer';
      case 'MOMO':
        return 'MoMo E-Wallet';
      default:
        return method;
    }
  }

  Widget _buildCreditCardForm(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credit Card Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Card Number
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.length < 13 || value.length > 19) {
              return 'Card number should be between 13-19 digits';
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
            labelText: 'Card Holder Name',
            hintText: 'Name on card',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card holder name';
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
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter expiry date';
                  }
                  if (!value.contains('/') || value.length != 5) {
                    return 'Use MM/YY format';
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
                    return 'Enter CVV';
                  }
                  if (value.length < 3) {
                    return 'Invalid CVV';
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
  
  Widget _buildBankTransferForm(PaymentProvider paymentProvider) {
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
          'Bank Transfer Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Bank name dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Bank Name',
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
              return 'Please select your bank';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Account number
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Account Number',
            hintText: 'Enter your bank account number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_box),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            if (value.length < 10) {
              return 'Account number should be at least 10 digits';
            }
            return null;
          },
          onChanged: (value) {
            paymentProvider.updateBankTransferData(accountNumber: value);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Optional transfer code
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Transfer Code (Optional)',
            hintText: 'Enter transfer reference code if available',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          onChanged: (value) {
            paymentProvider.updateBankTransferData(transferCode: value);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Bank transfer instructions
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
                      'Transfer Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('1. Transfer the exact amount to our account.'),
                const Text('2. Use your Order ID as reference.'),
                const Text('3. Your order will be processed after payment confirmation.'),
                const SizedBox(height: 8),
                Text('Amount to transfer: ${_formatCurrency(widget.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Account name: E-commerce Store JSC',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Account number: 12345678900',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Bank: Vietcombank',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMomoPaymentForm(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MoMo E-Wallet Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Phone number linked to MoMo account
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'MoMo Phone Number',
            hintText: 'Enter your MoMo-linked phone number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your MoMo phone number';
            }
            if (value.length != 10) {
              return 'Phone number should be 10 digits';
            }
            return null;
          },
          onChanged: (value) {
            paymentProvider.updateMomoPaymentData(phoneNumber: value);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Optional transaction ID
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Transaction ID (Optional)',
            hintText: 'Enter MoMo transaction ID if already paid',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          onChanged: (value) {
            paymentProvider.updateMomoPaymentData(transactionId: value);
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
                      'MoMo Payment Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('1. Open your MoMo app.'),
                const Text('2. Scan the QR code below or search for our MoMo number.'),
                const Text('3. Enter the exact amount and order ID as reference.'),
                const SizedBox(height: 16),
                // Centered QR code placeholder
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
                Text('Amount to transfer: ${_formatCurrency(widget.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('MoMo number: 0987654321',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Recipient name: E-commerce Store',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCodForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash on Delivery',
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
                      'Payment Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('You will pay cash to the delivery person when your order arrives.'),
                const SizedBox(height: 8),
                Text('Amount to pay on delivery: ${_formatCurrency(widget.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Make sure to have exact change if possible.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Delivery Notes (Optional)',
            hintText: 'Any special instructions for delivery',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}