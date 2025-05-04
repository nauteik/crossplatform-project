import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend_user/features/cart/presentation/screens/cart_screen.dart';
import 'package:frontend_user/features/cart/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  Widget _platformSpecificSizedBox(double width) {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return SizedBox(width: width);
    }
    return const SizedBox(width: 0);
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile =
        !(kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    return AppBar(
      backgroundColor: Colors.blue,
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _platformSpecificSizedBox(20),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? screenWidth * 0.8 : 600,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              _platformSpecificSizedBox(10)
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _navigateToCart(context),
          icon: Consumer<CartProvider>(
            builder: (context, cart, child) {
              final int itemCount = cart.itemCount; // <-- Lấy số lượng từ Provider

              return Stack(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white, size: 35),
                  // Chỉ hiển thị badge nếu số lượng lớn hơn 0
                  if (itemCount > 0) // <-- Kiểm tra số lượng
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CartBadgeWidget(count: itemCount),
                    )
                ],
              );
            },
          ),
        ),
        SizedBox(width: isMobile ? 10 : 20),
      ],
      centerTitle: isMobile,
    );
  }
}

class CartBadgeWidget extends StatelessWidget {
  final int count;
  
  const CartBadgeWidget({Key? key, required this.count}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
