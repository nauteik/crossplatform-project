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
    
    // Sử dụng LayoutBuilder để lấy kích thước thực của card
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Tính toán kích thước dựa trên không gian có sẵn
        final width = constraints.maxWidth;
        final deviceWidth = MediaQuery.of(context).size.width;
        
        // Điều chỉnh kích thước dựa trên chiều rộng thiết bị và số cột
        bool isNarrow = width < 150;
        double imageHeight;
        double fontSize;
        double priceSize;
        double textPadding;
        double iconSize;
        
        // Phát hiện số cột từ kích thước thiết bị
        int estimatedColumns = (deviceWidth / width).floor();
        
        if (estimatedColumns <= 2) {
          // Thiết lập cho 2 cột
          isNarrow = false;
          imageHeight = 120.0;
          fontSize = 12.0;
          priceSize = 13.0;
          textPadding = 8.0;
          iconSize = 14.0;
        } else if (estimatedColumns == 3) {
          // Thiết lập cho 3 cột
          imageHeight = 120.0;
          fontSize = 11.0;
          priceSize = 12.0;
          textPadding = 6.0;
          iconSize = 12.0;
        } else {
          // Thiết lập cho 4+ cột
          imageHeight = isNarrow ? 100.0 : 120.0;
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
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phần ảnh sản phẩm với tỷ lệ hình vuông
                      AspectRatio(
                        aspectRatio: 1.0, // Tỷ lệ hình vuông cho ảnh
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ảnh sản phẩm
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
                            
                            // Tag giảm giá
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
                              
                              // Nút yêu thích
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
                      
                      // Phần thông tin sản phẩm
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(textPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tên sản phẩm
                              Flexible(
                                flex: 3,
                                child: Text(
                                  name,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: textPadding / 2),
                              
                              const Spacer(flex: 1),
                              
                              // Giá sản phẩm
                              Text(
                                currencyFormatter.format(discountedPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: priceSize,
                                  color: Colors.red,
                                ),
                              ),
                              
                              // Giá gốc nếu có giảm giá
                              if (discountPercent > 0)
                                Text(
                                  currencyFormatter.format(price),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: fontSize - 1,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              
                              // Số lượng đã bán và đánh giá
                              SizedBox(height: textPadding / 2),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: iconSize),
                                  const SizedBox(width: 2),
                                  Text('4.8', 
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}