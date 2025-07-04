import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/product_model.dart';

class ProductInfo extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;

  const ProductInfo({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    
    final discountedPrice = product.price * (1 - product.discountPercent / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Discount, Brand and Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.discountPercent > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Giảm ${product.discountPercent.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Thương hiệu: ${product.brand['name'] ?? 'N/A'}',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 12,
                ),
              ),
            ),
            
            // Tags
            ...product.tags.map<Widget>((tag) {
              // Đảm bảo tag là Map để truy cập các thuộc tính
              final Map<String, dynamic> tagMap = tag is Map ? Map<String, dynamic>.from(tag) : {};
              final String tagName = tagMap['name'] ?? '';
              final String tagColor = tagMap['color'] ?? '#FF0000';
              
              // Chuyển đổi màu từ chuỗi hex sang Color
              Color color;
              try {
                color = Color(int.parse(tagColor.replaceAll('#', '0xFF')));
              } catch (e) {
                color = Colors.blue; // Màu mặc định nếu không thể parse
              }
              
              if (tagName.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  tagName,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
        
        // Product Name
        const SizedBox(height: 12),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Price information
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(discountedPrice),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            if (product.discountPercent > 0)
              Text(
                currencyFormatter.format(product.price),
                style: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        
        // sold count
        Row(
          children: [
            const SizedBox(width: 16),
            Text(
              'Đã bán: ${product.soldCount}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        
        // Divider
        const SizedBox(height: 16),
        const Divider(),
        
        // Quantity selector
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Số lượng:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: onDecrementQuantity,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncrementQuantity,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'Còn lại: ${product.quantity}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 