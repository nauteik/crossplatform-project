import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_type_provider.dart';
import 'package:intl/intl.dart';

class FilterSidebarWidget extends StatelessWidget {
  final Set<String> selectedProductTypes;
  final Set<String> selectedBrands;
  final Set<String> selectedTags;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final Function(String, bool) onProductTypeChanged;
  final Function(String, bool) onBrandChanged;
  final Function(String, bool)? onTagChanged;
  final Function() onResetFilters;
  final List<dynamic> brands;
  final List<dynamic> tags;

  const FilterSidebarWidget({
    super.key,
    required this.selectedProductTypes,
    required this.selectedBrands,
    this.selectedTags = const {},
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceRangeChanged,
    required this.onProductTypeChanged,
    required this.onBrandChanged,
    this.onTagChanged,
    required this.onResetFilters,
    required this.brands,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final typeProvider = Provider.of<ProductTypeProvider>(context);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc sản phẩm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Loại sản phẩm
          const Text(
            'Loại sản phẩm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...typeProvider.productTypes.map((type) {
            final isSelected = selectedProductTypes.contains(type.id);
            return CheckboxListTile(
              title: Text(type.name),
              value: isSelected,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (selected) => onProductTypeChanged(type.id, selected ?? false),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // Khoảng giá
          const Text(
            'Khoảng giá',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: priceRange,
            min: minPrice,
            max: maxPrice,
            divisions: 20,
            onChanged: onPriceRangeChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                  .format(priceRange.start)),
              Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                  .format(priceRange.end)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Thương hiệu
          const Text(
            'Thương hiệu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...brands.map((brand) {
            final brandId = brand['id']?.toString() ?? '';
            final isSelected = selectedBrands.contains(brandId);
            return CheckboxListTile(
              title: Text(brand['name']?.toString() ?? 'Unknown'),
              value: isSelected,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (selected) => onBrandChanged(brandId, selected ?? false),
            );
          }).toList(),
          
          // Tags - thêm mới
          if (tags.isNotEmpty && onTagChanged != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Thẻ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...tags.map((tag) {
              final tagId = tag['id']?.toString() ?? '';
              final isSelected = selectedTags.contains(tagId);
              return CheckboxListTile(
                title: Text(tag['name']?.toString() ?? 'Unknown'),
                value: isSelected,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (selected) => onTagChanged!(tagId, selected ?? false),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 24),
          
          // Nút đặt lại
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onResetFilters,
              child: const Text('Đặt lại tất cả'),
            ),
          ),
          // Thêm khoảng trống ở dưới cùng để tạo không gian cuộn
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 