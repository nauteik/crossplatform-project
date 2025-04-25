import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/model/cart_item_model.dart';
import '../../../utils/route_transitions.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../models/payment_request.dart';
import '../providers/payment_provider.dart';
import 'order_confirmation_screen.dart';

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
    });
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
                
                // Conditional Credit Card Form
                if (paymentProvider.selectedPaymentMethod == 'CREDIT_CARD')
                  _buildCreditCardForm(paymentProvider),
                
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
                      item.imageUrl.startsWith('http')
                          ? item.imageUrl
                          : '${ApiConstants.baseApiUrl}/${item.imageUrl}',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
      ],
    );
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
}