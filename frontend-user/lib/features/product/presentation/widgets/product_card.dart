import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/constants/api_constants.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final int soldCount;
  final double discountPercent;
  final String primaryImageUrl;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.soldCount,
    required this.discountPercent,
    required this.primaryImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final discountedPrice = price * (1 - discountPercent / 100);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(0.5),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(0.5),
          onTap: () {
            NavigationHelper.navigateToProductDetail(context, id);
          },
          // Use LayoutBuilder to constrain child sizes
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Section - Fixed height based on constraints
                  SizedBox(
                    height: constraints.maxWidth, // Square image
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(0.5)),
                          child: Image.network(
                            '${ApiConstants.baseApiUrl}/api/images/$primaryImageUrl',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 32)),
                              );
                            },
                          ),
                        ),
                        
                        // Discount badge
                        if (discountPercent > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${discountPercent.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          
                        // Quick action button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            child: IconButton(
                              iconSize: 20,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.favorite_border),
                              color: Colors.black54,
                              onPressed: () {
                                // Handle favorite button tap
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Product Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product name
                          const SizedBox(height: 1), // Reduced spacing
                          Text(
                          name,
                          maxLines: 1,  // Reduced to 1 line
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          ),
                          Row(
                          children: [
                            // Discounted price
                            Expanded(
                            child: Text(
                              currencyFormatter.format(discountedPrice),
                              style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 14,  // Slightly smaller
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            ),
                            // Original price if discounted
                            if (discountPercent > 0)
                            Text(
                              currencyFormatter.format(price),
                              style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 11,  // Smaller
                              color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          ),
                          
                          const SizedBox(height: 3), // Reduced spacing
                          
                          // Rating on the left, sold count on the right
                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rating on left
                            Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 15),
                              const SizedBox(width: 2),
                              const Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              ),
                            ],
                            ),
                            
                            // Sold count on right
                            Text(
                            'Đã bán: $soldCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}