import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/product_type_provider.dart';
import '../../../../../data/model/product_type_model.dart';

class FilterBarWidget extends StatelessWidget {
  final Set<String> selectedProductTypes;
  final Set<String> selectedBrands;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final bool showProductTypeGrid;
  final Function() onClearFilters;
  final Function(String) onRemoveProductType;
  final Function() showFilterDialog;
  final Function() showSortDialog;

  const FilterBarWidget({
    super.key,
    required this.selectedProductTypes,
    required this.selectedBrands,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.showProductTypeGrid,
    required this.onClearFilters,
    required this.onRemoveProductType,
    required this.showFilterDialog,
    required this.showSortDialog,
  });

  // Lấy tên loại sản phẩm từ id
  String _getProductTypeName(String typeId, ProductTypeProvider typeProvider) {
    final type = typeProvider.productTypes.firstWhere(
      (type) => type.id == typeId,
      orElse: () => ProductTypeModel(id: typeId, name: 'Unknown'),
    );
    return type.name;
  }

  @override
  Widget build(BuildContext context) {
    final typeProvider = Provider.of<ProductTypeProvider>(context);
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter button
                      ElevatedButton.icon(
                        onPressed: showFilterDialog,
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Lọc'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort button
                      ElevatedButton.icon(
                        onPressed: showSortDialog,
                        icon: const Icon(Icons.sort),
                        label: const Text('Sắp xếp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Hiển thị số lượng bộ lọc đã chọn
                      if (selectedProductTypes.isNotEmpty || selectedBrands.isNotEmpty)
                        Chip(
                          label: Text('${selectedProductTypes.length + selectedBrands.length} bộ lọc'),
                          deleteIcon: const Icon(Icons.clear, size: 18),
                          onDeleted: onClearFilters,
                        ),
                    ],
                  ),
                ),
              ),
              
              // Nút xem dạng grid/list (chỉ cho tablet)
              if (isTablet)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: const Icon(Icons.grid_view),
                    onPressed: () {
                      // Chức năng thay đổi kiểu hiển thị có thể thêm sau
                    },
                    tooltip: 'Thay đổi chế độ xem',
                  ),
                ),
            ],
          ),
          
          // Hiển thị các loại sản phẩm đã chọn
          if (selectedProductTypes.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: selectedProductTypes.map((typeId) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_getProductTypeName(typeId, typeProvider)),
                      deleteIcon: const Icon(Icons.clear, size: 16),
                      onDeleted: () => onRemoveProductType(typeId),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Thêm thông tin số lượng sản phẩm cho mobile
          if (!isTablet && !showProductTypeGrid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${Provider.of<ProductProvider>(context).getFilteredProducts().length} sản phẩm',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 