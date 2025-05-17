import 'package:flutter/material.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../payment/payment_feature.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;
  List<CartItemModel> items = [];
  
  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<CartProvider>(context, listen: false).fetchCart();
      items = Provider.of<CartProvider>(context, listen: false).items;
    } catch (e) {
      print('Error loading cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải giỏ hàng: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAuthenticated = authProvider.isAuthenticated;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadCartData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa giỏ hàng'),
                  content: const Text(
                      'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?'),
                  actions: [
                    TextButton(
                      child: const Text('Hủy'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    TextButton(
                      child: const Text('Xóa'),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).clearCart();
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Center(
                    child: Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, index) {
                          final item = cart.items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: cart.isItemSelected(item.id),
                                      onChanged: (_) => cart.toggleItemSelection(item.id),
                                    ),
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(ImageHelper.getImage(item.imageUrl)),
                                      backgroundColor: Colors.grey[200],
                                      onBackgroundImageError: (e, stackTrace) =>
                                          print('Image failed to load: $e'),
                                    ),
                                  ],
                                ),
                                title: Text(item.name),
                                subtitle: Text('${_formatCurrency(item.price)} x ${item.quantity}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Decrease quantity button - will remove item if quantity becomes 0
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          // Remove item if quantity would become 0
                                          if (item.quantity <= 1) {
                                            // Ask for confirmation before removing
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Xóa sản phẩm'),
                                                content: Text(
                                                    'Bạn có chắc muốn xóa ${item.name} khỏi giỏ hàng?'),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('Hủy'),
                                                    onPressed: () => Navigator.of(ctx).pop(),
                                                  ),
                                                  TextButton(
                                                    child: const Text('Xóa'),
                                                    onPressed: () {
                                                      Provider.of<CartProvider>(context, listen: false)
                                                          .removeItem(item.id);
                                                      Navigator.of(ctx).pop();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            // Just decrease the quantity
                                            _updateItemQuantity(item, item.quantity - 1);
                                          }
                                        },
                                      ),
                                    ),
                                    
                                    // Quantity display
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    
                                    // Increase quantity button
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _updateItemQuantity(item, item.quantity + 1),
                                      ),
                                    ),
                                    
                                    // Delete button
                                    Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Xóa sản phẩm'),
                                              content: Text(
                                                  'Bạn có chắc muốn xóa ${item.name} khỏi giỏ hàng?'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Hủy'),
                                                  onPressed: () => Navigator.of(ctx).pop(),
                                                ),
                                                TextButton(
                                                  child: const Text('Xóa'),
                                                  onPressed: () {
                                                    Provider.of<CartProvider>(context, listen: false)
                                                        .removeItem(item.id);
                                                    Navigator.of(ctx).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => cart.toggleItemSelection(item.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(15),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng tiền (đã chọn):',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              _formatCurrency(cart.selectedItems.isEmpty ? 0 : cart.selectedItemsTotalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed: cart.selectedItems.isEmpty
                            ? null
                            : () {
                                // Đối với người dùng chưa đăng nhập, hiển thị dialog giải thích
                                if (!isAuthenticated) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Thanh toán không cần đăng nhập'),
                                      content: const Text(
                                          'Bạn có thể thanh toán mà không cần đăng nhập. Hệ thống sẽ tự động tạo tài khoản dựa trên email của bạn và gửi thông tin đăng nhập qua email.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Hủy'),
                                          onPressed: () => Navigator.of(ctx).pop(),
                                        ),
                                        TextButton(
                                          child: const Text('Tiếp tục thanh toán'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            PaymentFeature.navigateToCheckout(
                                              context: context,
                                              userId: null, // Guest checkout
                                              cartItems: cart.selectedItems,
                                              totalAmount: cart.selectedItemsTotalPrice,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                
                                // Người dùng đã đăng nhập
                                PaymentFeature.navigateToCheckout(
                                  context: context,
                                  userId: authProvider.userId!,
                                  cartItems: cart.selectedItems,
                                  totalAmount: cart.selectedItemsTotalPrice,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          disabledBackgroundColor: Colors.grey,
                        disabledForegroundColor: Colors.white70,
                        ),
                        child: Text(
                          cart.selectedItems.isEmpty
                              ? 'CHỌN SẢN PHẨM'
                              : isAuthenticated 
                                ? 'THANH TOÁN (${cart.selectedItems.length} sản phẩm)'
                                : 'THANH TOÁN KHÔNG CẦN ĐĂNG NHẬP',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // Helper method to update item quantity
  void _updateItemQuantity(CartItemModel item, int newQuantity) {
    if (newQuantity < 1) return; // Don't allow quantity to go below 1
    
    Provider.of<CartProvider>(context, listen: false).updateItemQuantity(item.id, newQuantity);
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }
}
