import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';

class ProductTypeCard extends StatelessWidget {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const ProductTypeCard({
    super.key,
    required this.id,
    required this.name,
    this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ảnh loại sản phẩm
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    '${ApiConstants.baseApiUrl}/api/images/$imageUrl',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.category,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            
            // Tên loại sản phẩm
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
            
            // Biểu tượng đã chọn
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 