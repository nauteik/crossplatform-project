import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final int soldCount;
  final double discountPercent;
  final String primaryImageUrl;
  final double? rating;
  final List<dynamic>? tags;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.soldCount,
    required this.discountPercent,
    required this.primaryImageUrl,
    this.rating,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final discountedPrice = price * (1 - discountPercent / 100);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    
    final List<Map<String, dynamic>> activeTags = [];
    if (tags != null && tags!.isNotEmpty) {
      for (var tag in tags!) {
        if (tag is Map<String, dynamic> && 
            tag.containsKey('active') && 
            tag['active'] == true &&
            tag.containsKey('name') &&
            tag.containsKey('id')) {
          activeTags.add(Map<String, dynamic>.from(tag));
        }
      }
    }
    
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = constraints.maxWidth;
        final deviceWidth = MediaQuery.of(context).size.width;
        
        bool isNarrow = width < 150;
        double fontSize;
        double priceSize;
        double textPadding;
        double iconSize;
        
        int estimatedColumns = (deviceWidth / width).floor();
        
        if (estimatedColumns <= 2) {
          isNarrow = false;
          fontSize = 12.0;
          priceSize = 13.0;
          textPadding = 8.0;
          iconSize = 14.0;
        } else if (estimatedColumns == 3) {
          fontSize = 11.0;
          priceSize = 12.0;
          textPadding = 6.0;
          iconSize = 12.0;
        } else {
          fontSize = isNarrow ? 10.0 : 12.0;
          priceSize = isNarrow ? 11.0 : 13.0;
          textPadding = isNarrow ? 4.0 : 6.0;
          iconSize = 12.0;
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => NavigationHelper.navigateToProductDetail(context, id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Section
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            '${ApiConstants.baseApiUrl}/api/images/$primaryImageUrl',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image, 
                                size: width / 5, 
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        if (discountPercent > 0)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              child: Text(
                                '-${discountPercent.toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize - 1,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite_outline,
                                  size: iconSize,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tags Section
                  if (activeTags.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        left: textPadding, 
                        right: textPadding, 
                        top: textPadding / 2.5,
                        bottom: textPadding / 2.5
                      ),
                      child: Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: activeTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getTagColor(tag['color']),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize - 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  // Product Info Section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: textPadding, 
                        right: textPadding, 
                        bottom: textPadding, 
                        top: activeTags.isEmpty ? textPadding : textPadding / 3
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSize,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencyFormatter.format(discountedPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: priceSize,
                                  color: Colors.red,
                                ),
                              ),
                              if (discountPercent > 0)
                                Text(
                                  currencyFormatter.format(price),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: fontSize - 1,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              SizedBox(height: textPadding / 3),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: iconSize),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating == null ? 'N/A' : rating! > 0 ? rating!.toStringAsFixed(1) : '0.0',
                                    style: TextStyle(fontSize: fontSize - 1),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Đã bán $soldCount',
                                    style: TextStyle(fontSize: fontSize - 1),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getTagColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.blue; 
    }
    if (colorString.startsWith('#')) {
      try {
        String hexColor = colorString.replaceAll('#', '');
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse(hexColor, radix: 16));
      } catch (e) {
        return Colors.blue; 
      }
    }
    switch (colorString.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'yellow': return Colors.yellow.shade700; // Darker yellow for better readability
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'cyan': return Colors.cyan;
      case 'amber': return Colors.amber.shade700; // Darker amber
      case 'indigo': return Colors.indigo;
      case 'brown': return Colors.brown;
      case 'grey': return Colors.grey.shade600; // Darker grey
      case 'black': return Colors.black;
      default: return Colors.blue;
    }
  }
}