import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_type_provider.dart';
import '../product_type_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductTypeGridWidget extends StatelessWidget {
  final ProductTypeProvider typeProvider;
  final int crossAxisCount;
  final Set<String> selectedProductTypes;
  final Function(String) onProductTypeSelected;
  
  const ProductTypeGridWidget({
    super.key,
    required this.typeProvider,
    required this.crossAxisCount,
    required this.selectedProductTypes,
    required this.onProductTypeSelected,
  });

  Widget _buildErrorView(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                typeProvider.fetchProductTypes();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (typeProvider.productTypes.isEmpty) {
      if (typeProvider.status == ProductTypeStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      } else if (typeProvider.status == ProductTypeStatus.error) {
        return _buildErrorView('Không thể tải loại sản phẩm');
      } else {
        return const Center(child: Text('Không có loại sản phẩm nào.'));
      }
    }
    
    // Tính toán aspect ratio tốt nhất cho từng loại màn hình
    double childAspectRatio = kIsWeb ? 1.5 : 1.2;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề ở đầu lưới
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Text(
              'Chọn loại sản phẩm',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          
          // Lưới loại sản phẩm
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: typeProvider.productTypes.length,
              itemBuilder: (context, index) {
                final productType = typeProvider.productTypes[index];
                final isSelected = selectedProductTypes.contains(productType.id);
                
                return ProductTypeCard(
                  id: productType.id,
                  name: productType.name,
                  imageUrl: productType.image,
                  isSelected: isSelected,
                  onTap: () => onProductTypeSelected(productType.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 