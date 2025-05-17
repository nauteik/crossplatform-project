import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/image_helper.dart';
import '../../../data/model/cart_item_model.dart';
import '../../../data/model/order_model.dart';
import '../../../utils/route_transitions.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/payment_request.dart';
import '../providers/payment_provider.dart';
import 'order_confirmation_screen.dart';
import 'payment_method_widgets.dart';

class GuestCheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const GuestCheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<GuestCheckoutScreen> createState() => _GuestCheckoutScreenState();
}

class _GuestCheckoutScreenState extends State<GuestCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  
  // Controller cho thông tin người dùng guest
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();

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
    _emailController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    super.dispose();
  }
  
  void _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final paymentProvider = context.read<PaymentProvider>();
    
    try {
      // Chuẩn bị thông tin người dùng
      final Map<String, dynamic> userInfo = {
        'email': _emailController.text,
        'username': _usernameController.text,
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneController.text,
      };
      
      // Chuẩn bị thông tin địa chỉ
      final Map<String, dynamic> addressInfo = {
        'addressLine': _addressLineController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'ward': _wardController.text,
      };
      
      // Đặt thông tin vào PaymentProvider
      paymentProvider.setGuestCheckoutInfo(userInfo, addressInfo);
      
      // Tạo đơn hàng cho guest sử dụng API mới
      final orderCreated = await paymentProvider.createGuestOrder(context);
      
      if (!orderCreated) {
        _showErrorSnackbar(paymentProvider.errorMessage);
        setState(() => _isProcessing = false);
        return;
      }
      
      // Hiển thị thông báo tài khoản mới đã được tạo
      if (mounted && paymentProvider.newUsername != null && paymentProvider.newPassword != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tài khoản mới đã được tạo và tự động đăng nhập, kiểm tra email để xem chi tiết.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán cho khách'),
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
                
                // Thông tin người dùng
                _buildGuestUserForm(),
                
                const SizedBox(height: 24),
                
                // Thông tin địa chỉ
                _buildAddressForm(),
                
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
  
  Widget _buildGuestUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin khách hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Email (bắt buộc)
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            hintText: 'Email của bạn',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Username (bắt buộc)
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Tên đăng nhập *',
            hintText: 'Tên tài khoản đăng nhập',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên đăng nhập';
            }
            if (value.length < 4) {
              return 'Tên đăng nhập phải có ít nhất 4 ký tự';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Họ tên (bắt buộc)
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Họ tên *',
            hintText: 'Họ tên đầy đủ',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Số điện thoại (bắt buộc)
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại *',
            hintText: 'Số điện thoại liên hệ',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              return 'Số điện thoại phải có 10 chữ số';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        const Text(
          'Thông tin về tài khoản mới sẽ được gửi vào email của bạn sau khi đặt hàng thành công.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Địa chỉ giao hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Địa chỉ chi tiết
        TextFormField(
          controller: _addressLineController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ chi tiết *',
            hintText: 'Số nhà, đường, khu phố,...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập địa chỉ chi tiết';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Tỉnh/Thành phố
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'Tỉnh/Thành phố *',
            hintText: 'Ví dụ: Hồ Chí Minh',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tỉnh/thành phố';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Quận/Huyện
        TextFormField(
          controller: _districtController,
          decoration: const InputDecoration(
            labelText: 'Quận/Huyện *',
            hintText: 'Ví dụ: Quận 1',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập quận/huyện';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Phường/Xã
        TextFormField(
          controller: _wardController,
          decoration: const InputDecoration(
            labelText: 'Phường/Xã *',
            hintText: 'Ví dụ: Phường Bến Nghé',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập phường/xã';
            }
            return null;
          },
        ),
      ],
    );
  }
} 