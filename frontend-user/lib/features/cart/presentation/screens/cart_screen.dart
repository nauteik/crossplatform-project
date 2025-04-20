import 'package:flutter/material.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

// Changed from StatelessWidget to StatefulWidget
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Add a loading state
  var _isLoading = false;
  List<CartItemModel> items = [];

  @override
  void initState() {
    // Call the data loading function when the screen initializes
    super.initState();
    // We use Future.microtask or a small delay to avoid calling
    // Provider.of in initState directly before the widget is fully built.
    // Alternatively, use listen: false which is safe in initState.
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Access the provider using listen: false as we are in initState
      // We only need to call a method, not rebuild based on its changes here
      await Provider.of<CartProvider>(context, listen: false).fetchCart();
      items = Provider.of<CartProvider>(context, listen: false).items;
    } catch (e) {
      // Handle potential errors during loading (e.g., show a snackbar)
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
    // Consumer is still used here to react to provider changes AFTER loading
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
              // Clear cart confirmation
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
                        // Using listen: false here as it's inside a button press handler
                        Provider.of<CartProvider>(context, listen: false)
                            .clearCart();
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
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Center(
                    child:
                        Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, index) {
                          final item = cart.items[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              // Using listen: false here
                              Provider.of<CartProvider>(context, listen: false)
                                  .removeItem(item.id);
                              // Optionally show a snackbar confirming removal
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${item.name} đã xóa khỏi giỏ hàng'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(item.imageUrl),
                                    backgroundColor:
                                        Colors.grey[200], // Placeholder color
                                    onBackgroundImageError: (e, stackTrace) =>
                                        print(
                                            'Image failed to load: $e'), // Handle image loading errors
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(
                                      '${_formatCurrency(item.price)} x ${item.quantity}'),
                                  trailing: Text(
                                    _formatCurrency(item.price * item.quantity),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // TODO: Add quantity adjustment buttons here if needed
                                ),
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
                              'Tổng tiền:',
                              style: TextStyle(fontSize: 18),
                            ),
                            // Use Text.rich for potentially different styles if needed,
                            // but simple Text is fine here.
                            Text(
                              _formatCurrency(cart.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue, // Or Colors.blue
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        // Disable button if cart is empty
                        onPressed: cart.itemCount <= 0
                            ? null
                            : () {
                                // Xử lý chức năng thanh toán
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Chức năng thanh toán sẽ được triển khai sau'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // TODO: Navigate to checkout screen
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          // Disable button color if disabled
                          disabledBackgroundColor: Colors.grey,
                          disabledForegroundColor: Colors.white70,
                        ),
                        child: const Text(
                          'THANH TOÁN',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }
}
