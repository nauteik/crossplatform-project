import 'package:flutter/material.dart';

class ProductBottomSheet extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isLoadingAddToCart;

  const ProductBottomSheet({
    super.key,
    required this.onAddToCart,
    required this.onBuyNow,
    this.isLoadingAddToCart = false, // <-- Initialize with a default value
  });

  @override
  Widget build(BuildContext context) {
    // Lấy padding bottom an toàn của thiết bị
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea( // Add SafeArea if not already handled by parent Scaffold
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                // Conditionally hide icon when loading
                icon: isLoadingAddToCart ? const SizedBox.shrink() : const Icon(Icons.shopping_cart_outlined),
                 // Conditionally show loading indicator or text label
                label: isLoadingAddToCart
                    ? const SizedBox( // Use a SizedBox to constrain the CircularProgressIndicator size
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0, // Adjust thickness
                        ),
                      )
                    : const Text('Thêm vào giỏ hàng'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                // Disable button while loading
                onPressed: isLoadingAddToCart ? null : onAddToCart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onBuyNow, // Assuming Buy Now doesn't need a loading state for this feature
                child: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}