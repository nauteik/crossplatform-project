import 'package:flutter/material.dart';
import '../../../../data/model/product_model.dart';

class ProductSpecifications extends StatelessWidget {
  final ProductModel product;

  const ProductSpecifications({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông Số Kỹ Thuật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSpecItem('Loại sản phẩm', product.productType['name'] ?? 'N/A'),
                _buildSpecItem('Thương hiệu', product.brand['name'] ?? 'N/A'),
                _buildSpecItem('Mã sản phẩm', product.id),
                _buildSpecItem('Bảo hành', '24 tháng'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 