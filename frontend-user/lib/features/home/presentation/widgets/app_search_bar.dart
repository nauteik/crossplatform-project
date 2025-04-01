import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend_user/features/cart/presentation/screens/cart_screen.dart';

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
    final isMobile = !(kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    
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
                    maxWidth: isMobile 
                        ? screenWidth * 0.8
                        : 600,
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
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
          icon: const Stack(
            children: [
              Icon(Icons.shopping_cart, color: Colors.white, size: 35),
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 9,
                  child: Text(
                    '0',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
            ],
          ),
          onPressed: () => _navigateToCart(context),
        ),
        SizedBox(width: isMobile ? 10 : 20),
      ],
      centerTitle: isMobile,
    );
  }
} 