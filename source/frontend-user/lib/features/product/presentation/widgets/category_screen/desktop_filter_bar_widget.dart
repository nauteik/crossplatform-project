import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';

class DesktopFilterBarWidget extends StatelessWidget {
  final String sortBy;
  final Function(String?) onChangeSortBy;
  final int productCount;
  final VoidCallback? onBackToCategories;
  
  const DesktopFilterBarWidget({
    super.key, 
    required this.sortBy,
    required this.onChangeSortBy,
    this.productCount = 0,
    this.onBackToCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          // Hiển thị số lượng sản phẩm tìm thấy
          Text(
            '$productCount sản phẩm',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // // Nút quay lại danh sách loại sản phẩm (nếu được cung cấp)
          // if (onBackToCategories != null)
          //   TextButton.icon(
          //     onPressed: onBackToCategories,
          //     icon: const Icon(Icons.category, size: 18),
          //     label: const Text('Xem loại sản phẩm'),
          //     style: TextButton.styleFrom(
          //       foregroundColor: Colors.blue,
          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     ),
          //   ),
          
          const Spacer(),
          
          // Dropdown sắp xếp
          Row(
            children: [
              const Text('Sắp xếp theo: ', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: sortBy,
                  isDense: true,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'relevance',
                      child: Text('Mặc định', style: TextStyle(color: sortBy == 'relevance' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Giá thấp đến cao', style: TextStyle(color: sortBy == 'price_asc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Giá cao đến thấp', style: TextStyle(color: sortBy == 'price_desc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'name_asc',
                      child: Text('Tên A-Z', style: TextStyle(color: sortBy == 'name_asc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'name_desc',
                      child: Text('Tên Z-A', style: TextStyle(color: sortBy == 'name_desc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'rating_desc',
                      child: Text('Đánh giá cao nhất', style: TextStyle(color: sortBy == 'rating_desc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'rating_asc',
                      child: Text('Đánh giá thấp nhất', style: TextStyle(color: sortBy == 'rating_asc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'created_desc',
                      child: Text('Mới nhất', style: TextStyle(color: sortBy == 'created_desc' ? Colors.blue : null)),
                    ),
                    DropdownMenuItem(
                      value: 'created_asc',
                      child: Text('Cũ nhất', style: TextStyle(color: sortBy == 'created_asc' ? Colors.blue : null)),
                    ),
                  ],
                  onChanged: onChangeSortBy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 