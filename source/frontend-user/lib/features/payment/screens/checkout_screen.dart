import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/address_model.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/model/cart_item_model.dart';
import '../../../data/model/order_model.dart';
import '../../../utils/route_transitions.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/data/repositories/address_provider.dart';
import '../models/payment_request.dart';
import '../providers/payment_provider.dart';
import 'order_confirmation_screen.dart';
import '../../../core/utils/image_helper.dart';

class CheckoutScreen extends StatefulWidget {
  final String? userId; // userId có thể null nếu người dùng chưa đăng nhập
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    this.userId,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  AddressModel? _selectedAddress;
  bool _isAuthenticated = false;
  
  // Controller cho thông tin địa chỉ
  final _addressController = TextEditingController();
  
  // Controller cho thông tin người dùng guest
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kiểm tra trạng thái đăng nhập
    final authProvider = context.read<AuthProvider>();
    _isAuthenticated = authProvider.isAuthenticated;
    
    // Load available payment methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.loadPaymentMethods();
      
      // Set the selected item IDs in the payment provider
      final List<String> itemIds = widget.cartItems.map((item) => item.id).toList();
      paymentProvider.setSelectedItemIds(itemIds);
      
      // Load user addresses nếu đã đăng nhập
      if (_isAuthenticated && widget.userId != null) {
        _loadUserAddresses();
      }
    });
  }

  Future<void> _loadUserAddresses() async {
    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressProvider>();
    
    if (authProvider.isAuthenticated && authProvider.token != null && widget.userId != null) {
      await addressProvider.fetchUserAddresses(
        widget.userId!,
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
    _emailController.dispose();
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
      // Chuẩn bị dữ liệu thanh toán
      if (_isAuthenticated) {
        // Đã đăng nhập - sử dụng địa chỉ đã chọn hoặc đã nhập
        if (_selectedAddress != null) {
          paymentProvider.setShippingAddress(_selectedAddress!.fullAddress);
        } else {
          paymentProvider.setShippingAddress(_addressController.text);
        }
        
        // Step 1: Create Order với userId hiện tại
        final orderCreated = await paymentProvider.createOrder(widget.userId!);
        
        if (!orderCreated) {
          _showErrorSnackbar(paymentProvider.errorMessage);
          setState(() => _isProcessing = false);
          return;
        }
      } else {
        // Chưa đăng nhập - Tạo tài khoản guest
        // Chuẩn bị thông tin người dùng
        final Map<String, dynamic> userInfo = {
          'email': _emailController.text,
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
        
        // Tạo đơn hàng cho guest
        final orderCreated = await paymentProvider.createGuestOrder();
        
        if (!orderCreated) {
          _showErrorSnackbar(paymentProvider.errorMessage);
          setState(() => _isProcessing = false);
          return;
        }
        
        // Nếu tạo tài khoản thành công, cập nhật trạng thái đăng nhập
        if (paymentProvider.newUserToken != null && paymentProvider.newUserId != null) {
          // Lưu token và userId mới
          final authProvider = context.read<AuthProvider>();
          await authProvider.setTokenAndUserId(
            paymentProvider.newUserToken!, 
            paymentProvider.newUserId!
          );
          
          // Hiển thị thông báo tài khoản mới đã được tạo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tài khoản mới đã được tạo. Vui lòng kiểm tra email để lấy mật khẩu.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
      
      // Step 2: Process Payment
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
                
                // Hiển thị form thông tin người dùng nếu chưa đăng nhập
                if (!_isAuthenticated)
                  _buildGuestUserForm(),
                
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
                  'Tổng cộng',
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
            else if (_isAuthenticated)
              // Người dùng đã đăng nhập nhưng chưa chọn địa chỉ
              Column(
                children: [
                  // Nhập địa chỉ mới nếu chưa có địa chỉ đã chọn
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
              )
            else
              // Người dùng chưa đăng nhập - hiển thị form địa chỉ chi tiết
              Column(
                children: [
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
          'Phương thức thanh toán',
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

  Widget _buildCreditCardForm(PaymentProvider paymentProvider) {
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
        
        // Optional transfer code
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Mã chuyển khoản (Tùy chọn)',
            hintText: 'Nhập mã chuyển khoản nếu có',
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
                Text('Số tiền chuyển: ${_formatCurrency(widget.totalAmount)}',
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
  
  Widget _buildMomoPaymentForm(PaymentProvider paymentProvider) {
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
        
        // Optional transaction ID
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Mã giao dịch (Tùy chọn)',
            hintText: 'Nhập ID giao dịch MoMo nếu đã thanh toán',
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
                const Text('2. Quét mã QR code bên dưới hoặc tìm kiếm số điện thoại MoMo của chúng tôi.'),
                const Text('3. Nhập đúng số tiền và ID đơn hàng làm tham chiếu.'),
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
                Text('Số tiền chuyển: ${_formatCurrency(widget.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Số điện thoại MoMo: 0987654321',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Tên người nhận: Cửa hàng E-commerce',
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
                Text('Số tiền thanh toán: ${_formatCurrency(widget.totalAmount)}',
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

  // Form thông tin người dùng khi chưa đăng nhập
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
}