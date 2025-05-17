import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/address_model.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/image_helper.dart';
import '../../../data/model/cart_item_model.dart';
import '../../../data/model/order_model.dart';
import '../../../utils/route_transitions.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/data/repositories/address_provider.dart';
import '../../../features/profile/presentation/screens/address_screen.dart';
import '../models/payment_request.dart';
import '../providers/payment_provider.dart';
import 'order_confirmation_screen.dart';
import 'payment_method_widgets.dart';
import 'address_selection_screen.dart';

class UserCheckoutScreen extends StatefulWidget {
  final String userId;
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const UserCheckoutScreen({
    super.key,
    required this.userId,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<UserCheckoutScreen> createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  AddressModel? _selectedAddress;
  
  // Controller cho thông tin địa chỉ
  final _addressController = TextEditingController();

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
    
    if (authProvider.token != null) {
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
    
    try {
      // Đã đăng nhập - sử dụng địa chỉ đã chọn hoặc đã nhập
      if (_selectedAddress != null) {
        paymentProvider.setSelectedAddress(_selectedAddress!);
      } else {
        paymentProvider.setShippingAddress(_addressController.text);
      }
      
      // Tạo đơn hàng với userId hiện tại
      final orderCreated = await paymentProvider.createOrder(widget.userId);
      
      if (!orderCreated) {
        _showErrorSnackbar(paymentProvider.errorMessage);
        setState(() => _isProcessing = false);
        return;
      }
      
      // Xử lý thanh toán
      final paymentSuccess = await paymentProvider.processPayment();
      
      if (paymentSuccess) {
        // Get cart provider to remove paid items
        final cartProvider = context.read<CartProvider>();
        
        // Get the list of paid item IDs
        final paidItemIds = widget.cartItems.map((item) => item.id).toList();
        
        // Remove the paid items from the cart
        await cartProvider.removePaidItems(paidItemIds);
        
        // Navigate to confirmation page using slide transition
        if (mounted) {
          Navigator.of(context).pushReplacement(
            SlideRightRoute(
              page: OrderConfirmationScreen(
                order: OrderModel.fromJson(paymentProvider.currentOrder!),
              ),
            ),
          );
        }
      } else {
        _showErrorSnackbar(paymentProvider.errorMessage);
      }
    } catch (e) {
      _showErrorSnackbar("Đã xảy ra lỗi: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _selectAddress() async {
    final address = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (context) => AddressSelectionScreen(
          userId: widget.userId,
        ),
      ),
    );
    
    if (address != null) {
      setState(() {
        _selectedAddress = address;
        _addressController.text = address.fullAddress;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
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
                _buildShippingAddressSection(),
                
                const SizedBox(height: 24),
                
                // Payment Method Selection
                PaymentMethodWidgets.buildPaymentMethodSelection(paymentProvider, context),
                
                const SizedBox(height: 24),
                
                // Conditional Payment Form based on selection
                if (paymentProvider.selectedPaymentMethod == 'CREDIT_CARD')
                  PaymentMethodWidgets.buildCreditCardForm(paymentProvider, context)
                else if (paymentProvider.selectedPaymentMethod == 'BANK_TRANSFER')
                  PaymentMethodWidgets.buildBankTransferForm(paymentProvider, context, widget.totalAmount)
                else if (paymentProvider.selectedPaymentMethod == 'MOMO')
                  PaymentMethodWidgets.buildMomoPaymentForm(paymentProvider, context, widget.totalAmount)
                else if (paymentProvider.selectedPaymentMethod == 'COD')
                  PaymentMethodWidgets.buildCodForm(context, widget.totalAmount),
                
                const SizedBox(height: 32),
                
                // Checkout Button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đặt hàng', style: TextStyle(fontSize: 16)),
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
              'Tóm tắt đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                          '${item.quantity} x ${PaymentMethodWidgets.formatCurrency(item.price)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    PaymentMethodWidgets.formatCurrency(item.quantity * item.price),
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
                  'Tổng cộng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  PaymentMethodWidgets.formatCurrency(widget.totalAmount),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShippingAddressSection() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ giao hàng',
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
              // Người dùng chưa chọn địa chỉ
              Column(
                children: [
                  // Nhập địa chỉ mới
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập địa chỉ giao hàng của bạn',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ giao hàng của bạn';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // No need to update provider, will be done at checkout
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
} 