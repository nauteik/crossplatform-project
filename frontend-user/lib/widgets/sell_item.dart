import 'package:flutter/material.dart';
class SellItem extends StatelessWidget {
  final String name;
  final double price;
  final int soldCount;
  final double discountPercent;
  final String imageUrl;

  const SellItem({
    super.key,
    required this.name,
    required this.price,
    required this.soldCount,
    required this.discountPercent,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(imageUrl),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giá: ${price.toStringAsFixed(0)} VND'),
          Text('Đã bán: $soldCount'),
          Text('Giảm giá: ${discountPercent.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}
