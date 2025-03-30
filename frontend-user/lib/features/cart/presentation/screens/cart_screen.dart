import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dữ liệu mẫu cho giỏ hàng
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Laptop Gaming Asus ROG',
      price: 25000000,
      quantity: 1,
      imageUrl: 'https://picsum.photos/200',
    ),
    CartItem(
      id: '2',
      name: 'Chuột Gaming Logitech G502',
      price: 1200000,
      quantity: 2,
      imageUrl: 'https://picsum.photos/200',
    ),
  ];

  double get totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _cartItems.isEmpty
            ? const Center(
                child: Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (ctx, index) {
                        final item = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(item.imageUrl),
                              ),
                              title: Text(item.name),
                              subtitle: Text('${_formatCurrency(item.price)} x ${item.quantity}'),
                              trailing: Text(
                                _formatCurrency(item.price * item.quantity),
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                          Text(
                            _formatCurrency(totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý chức năng thanh toán
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chức năng thanh toán sẽ được triển khai sau'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'THANH TOÁN',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }
} 