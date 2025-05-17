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
import '../../../features/profile/presentation/screens/address_form_screen.dart';
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
  final _couponController = TextEditingController();
  
  // Controller cho loyalty points
  TextEditingController _loyaltyPointsController = TextEditingController();
  bool _useLoyaltyPoints = false;

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
      
      // Load user loyalty points
      _loadUserLoyaltyPoints();
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

  Future<void> _loadUserLoyaltyPoints() async {
    final authProvider = context.read<AuthProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    
    if (authProvider.token != null) {
      await paymentProvider.loadUserLoyaltyPoints(
        widget.userId,
        authProvider.token,
      );
      
      // Khởi tạo controller với giá trị 0
      _loyaltyPointsController.text = "0";
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _couponController.dispose();
    _loyaltyPointsController.dispose();
    super.dispose();
  }
  
  void _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final paymentProvider = context.read<PaymentProvider>();
    
    try {
      // Kiểm tra xem đã có địa chỉ giao hàng chưa
      if (_selectedAddress == null) {
        _showErrorSnackbar("Vui lòng chọn hoặc thêm địa chỉ giao hàng trước khi đặt hàng");
        setState(() => _isProcessing = false);
        return;
      }
      
      // Đã đăng nhập - sử dụng địa chỉ đã chọn
      if (_selectedAddress != null) {
        paymentProvider.setSelectedAddress(_selectedAddress!);
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
  
  // Thêm địa chỉ mới
  Future<void> _addNewAddress() async {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm địa chỉ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (context) => const AddressFormScreen(),
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedAddress = result;
        _addressController.text = result.fullAddress;
      });
      
      // Refresh danh sách địa chỉ
      _loadUserAddresses();
    }
  }
  
  // Kiểm tra coupon
  Future<void> _checkCoupon() async {
    final paymentProvider = context.read<PaymentProvider>();
    String couponCode = _couponController.text.trim();
    
    if (couponCode.isEmpty) {
      _showErrorSnackbar('Vui lòng nhập mã giảm giá');
      return;
    }
    
    final isValid = await paymentProvider.checkCoupon(couponCode);
    
    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã giảm giá hợp lệ'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorSnackbar(paymentProvider.errorMessage);
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
                
                // Coupon Field
                _buildCouponSection(paymentProvider),
                
                const SizedBox(height: 24),
                
                // Loyalty Points Section
                _buildLoyaltyPointsSection(paymentProvider),
                
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
  
  Widget _buildCouponSection(PaymentProvider paymentProvider) {
    // Tính toán số tiền sau khi áp dụng coupon
    double finalAmount = widget.totalAmount;
    double couponValue = 0;
    
    if (paymentProvider.isCouponValid && paymentProvider.couponDetails != null) {
      // Xử lý value có thể là int hoặc double
      final dynamic rawValue = paymentProvider.couponDetails!['value'];
      if (rawValue is int) {
        couponValue = rawValue.toDouble();
      } else if (rawValue is double) {
        couponValue = rawValue;
      }
      finalAmount = widget.totalAmount - couponValue;
      if (finalAmount < 0) finalAmount = 0;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mã giảm giá',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _couponController,
                decoration: const InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  border: OutlineInputBorder(),
                ),
                enabled: !paymentProvider.isCheckingCoupon && !paymentProvider.isCouponValid,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: paymentProvider.isCheckingCoupon || paymentProvider.isCouponValid 
                  ? null 
                  : _checkCoupon,
                child: paymentProvider.isCheckingCoupon 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : paymentProvider.isCouponValid
                    ? const Icon(Icons.check)
                    : const Text('Áp dụng'),
              ),
            ),
          ],
        ),
        
        if (paymentProvider.isCouponValid && paymentProvider.couponDetails != null) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.green.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã giảm giá: ${paymentProvider.couponCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          paymentProvider.setCouponCode('');
                          _couponController.clear();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giảm giá: ${PaymentMethodWidgets.formatCurrency(couponValue)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Số lần sử dụng còn lại: ${paymentProvider.couponDetails!['remainingUses']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng sau giảm giá:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                PaymentMethodWidgets.formatCurrency(finalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ],
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
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bạn chưa có địa chỉ giao hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Các nút hành động
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectAddress,
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('Chọn địa chỉ'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _addNewAddress,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Thêm mới'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoyaltyPointsSection(PaymentProvider paymentProvider) {
    if (paymentProvider.userLoyaltyPoints <= 0) {
      return const SizedBox.shrink(); // Ẩn nếu không có điểm
    }
    
    // Tính toán số tiền giảm giá khi sử dụng điểm
    double loyaltyDiscount = paymentProvider.loyaltyPointsDiscount;
    
    // Tính tổng giá trị sau khi áp dụng tất cả giảm giá
    double couponValue = 0;
    if (paymentProvider.isCouponValid && paymentProvider.couponDetails != null) {
      final dynamic rawValue = paymentProvider.couponDetails!['value'];
      if (rawValue is int) {
        couponValue = rawValue.toDouble();
      } else if (rawValue is double) {
        couponValue = rawValue;
      }
    }
    
    double finalAmount = widget.totalAmount - couponValue - loyaltyDiscount;
    if (finalAmount < 0) finalAmount = 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm thưởng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.blue.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị số điểm hiện có
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Điểm hiện có: ${paymentProvider.userLoyaltyPoints}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Giá trị: ${PaymentMethodWidgets.formatCurrency(paymentProvider.userLoyaltyPoints * 1000)}',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Switch để bật/tắt sử dụng điểm
                Row(
                  children: [
                    Switch(
                      value: _useLoyaltyPoints,
                      onChanged: (value) {
                        setState(() {
                          _useLoyaltyPoints = value;
                          if (!value) {
                            // Nếu tắt sử dụng điểm, reset về 0
                            _loyaltyPointsController.text = "0";
                            paymentProvider.setLoyaltyPointsToUse(0);
                          }
                        });
                      },
                    ),
                    const Text(
                      'Sử dụng điểm thưởng',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                
                if (_useLoyaltyPoints) ...[
                  const SizedBox(height: 16),
                  
                  // Nhập số điểm muốn sử dụng
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _loyaltyPointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Số điểm muốn sử dụng',
                            hintText: 'Tối đa ${paymentProvider.userLoyaltyPoints} điểm',
                            border: const OutlineInputBorder(),
                            suffixText: 'điểm',
                          ),
                          onChanged: (value) {
                            int points = 0;
                            try {
                              points = int.parse(value);
                            } catch (e) {
                              points = 0;
                            }
                            
                            // Không cho phép sử dụng quá số điểm hiện có
                            if (points > paymentProvider.userLoyaltyPoints) {
                              points = paymentProvider.userLoyaltyPoints;
                              _loyaltyPointsController.text = points.toString();
                            }
                            
                            paymentProvider.setLoyaltyPointsToUse(points);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Sử dụng tối đa điểm
                          setState(() {
                            int maxPoints = paymentProvider.userLoyaltyPoints;
                            _loyaltyPointsController.text = maxPoints.toString();
                            paymentProvider.setLoyaltyPointsToUse(maxPoints);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                        child: const Text('Tối đa'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Hiển thị số tiền sẽ được giảm
                  if (paymentProvider.loyaltyPointsToUse > 0)
                    Text(
                      'Giảm giá: ${PaymentMethodWidgets.formatCurrency(loyaltyDiscount)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
                
                const SizedBox(height: 8),
                const Divider(),
                
                // Hiển thị tổng sau khi giảm giá (nếu có sử dụng điểm)
                if (paymentProvider.loyaltyPointsToUse > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng đơn hàng sau giảm giá:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        PaymentMethodWidgets.formatCurrency(finalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                
                // Hiển thị điểm sẽ nhận được
                const SizedBox(height: 8),
                Text(
                  'Điểm thưởng nhận được sau đơn hàng: ${(finalAmount * 0.1 / 1000).floor()} điểm',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 