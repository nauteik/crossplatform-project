import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../product/providers/product_provider.dart';
import '../../../../data/model/product_model.dart';
import '../widgets/app_search_bar.dart';
import '../../../product/providers/product_type_provider.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../data/model/tag_model.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    // Fetch products and product types when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isRetrying = true;
      });
      
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
      
      await productProvider.fetchProducts();
      await typeProvider.fetchProductTypes();
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppSearchBar(),
      ),
      body: Consumer2<ProductProvider, ProductTypeProvider>(
        builder: (context, productProvider, productTypeProvider, child) {
          final productsStatus = productProvider.status;
          final products = productProvider.products;
          
          final typesStatus = productTypeProvider.status;
          final productTypes = productTypeProvider.productTypes;

          if (_isRetrying) {
            return const Center(child: CircularProgressIndicator());
          } else if (productsStatus == ProductStatus.loading || typesStatus == ProductTypeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (productsStatus == ProductStatus.error) {
            return _buildErrorView(
              'Không thể tải sản phẩm',
              productProvider.errorMessage,
              _loadData,
            );
          } else if (typesStatus == ProductTypeStatus.error) {
            // Trong trường hợp lỗi loại sản phẩm, vẫn hiển thị sản phẩm nhưng sẽ bỏ qua các section theo loại
            developer.log("Warning: Product types loading failed but products loaded successfully");
            developer.log("Error message: ${productTypeProvider.errorMessage}");
            
            return _buildMainContent(products, []);
          }

          if (products.isEmpty) {
            return const Center(
              child: Text('Không có sản phẩm nào'),
            );
          }

          return _buildMainContent(products, productTypes);
        },
      ),
    );
  }

  Widget _buildErrorView(String title, String message, VoidCallback onRetry) {
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isRetrying ? null : onRetry,
              child: _isRetrying 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<ProductModel> products, List<dynamic> productTypes) {
    // Nhóm sản phẩm theo tags (chỉ sử dụng các tags có active = true)
    final Map<String, List<ProductModel>> productsByTag = {};
    final Map<String, String> tagNameMap = {}; // Ánh xạ từ tag ID sang tag name
    
    // Danh sách các tag đặc biệt cần theo dõi
    const String promotionalTagName = 'Khuyến mãi';
    const String bestSellerTagName = 'Bán chạy';
    const String newTagName = 'Mới';
    
    // 1. Duyệt qua danh sách sản phẩm và nhóm theo tags (chỉ lấy những tag active = true)
    for (var product in products) {
      if (product.tags.isNotEmpty) {
        for (var tag in product.tags) {
          // Chỉ xử lý các tag có dạng Map và có trường active = true
          if (tag is Map<String, dynamic> && 
              tag.containsKey('active') && 
              tag['active'] == true && 
              tag.containsKey('id') && 
              tag.containsKey('name')) {
              
            final tagId = tag['id'].toString();
            final tagName = tag['name'].toString();
            
            // Lưu tên tag để hiển thị
            tagNameMap[tagId] = tagName;
            
            // Thêm sản phẩm vào danh sách tương ứng với tag
            if (!productsByTag.containsKey(tagId)) {
              productsByTag[tagId] = [];
            }
            productsByTag[tagId]!.add(product);
          }
        }
      }
    }
    
    // 2. Hiển thị lên giao diện
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          // Promotional Banner
          _buildPromotionalBanner(),
          
          // Hiển thị các section dựa trên tags - ưu tiên các tag đặc biệt trước
          // Ưu tiên hiển thị "Sản phẩm khuyến mãi" nếu có
          ..._buildSpecialTagSection(productsByTag, tagNameMap, promotionalTagName, 'SẢN PHẨM KHUYẾN MÃI'),
          
          // Ưu tiên hiển thị "Sản phẩm bán chạy" nếu có
          ..._buildSpecialTagSection(productsByTag, tagNameMap, bestSellerTagName, 'SẢN PHẨM BÁN CHẠY'),
          
          // Ưu tiên hiển thị "Sản phẩm mới" nếu có
          ..._buildSpecialTagSection(productsByTag, tagNameMap, newTagName, 'SẢN PHẨM MỚI'),
          
          // Hiển thị các tag khác nếu có
          for (var entry in productsByTag.entries) 
            if (!_isSpecialTag(tagNameMap[entry.key] ?? '', [promotionalTagName, bestSellerTagName, newTagName]))
              ...[
                _buildSectionTitle((tagNameMap[entry.key] ?? 'SẢN PHẨM').toUpperCase()),
                entry.value.isEmpty 
                    ? _buildEmptySection() 
                    : _buildHorizontalProductList(entry.value.take(10).toList()),
              ],
          
          // Nhóm sản phẩm theo loại sản phẩm
          ..._buildProductTypesSections(products, productTypes),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
  
  // Phương thức để kiểm tra xem một tag có phải là tag đặc biệt không
  bool _isSpecialTag(String tagName, List<String> specialTags) {
    return specialTags.contains(tagName);
  }
  
  // Phương thức để xây dựng section cho một tag đặc biệt
  List<Widget> _buildSpecialTagSection(
    Map<String, List<ProductModel>> productsByTag, 
    Map<String, String> tagNameMap, 
    String targetTagName,
    String sectionTitle
  ) {
    // Tìm tagId có tên trùng với targetTagName và có active=true
    List<String> targetTagIds = [];
    
    // Duyệt tất cả các tag ID được ánh xạ tới tên tag
    for (var entry in tagNameMap.entries) {
      if (entry.value == targetTagName) {
        targetTagIds.add(entry.key);
      }
    }
    
    // Kiểm tra xem có tag nào thỏa mãn không
    List<ProductModel> tagProducts = [];
    
    // Gộp tất cả sản phẩm từ tất cả các tagId tương ứng với targetTagName
    for (var tagId in targetTagIds) {
      if (productsByTag.containsKey(tagId) && productsByTag[tagId]!.isNotEmpty) {
        tagProducts.addAll(productsByTag[tagId]!);
      }
    }
    
    // Lọc trùng lặp
    tagProducts = _removeDuplicateProducts(tagProducts);
    
    // Nếu có sản phẩm, trả về section
    if (tagProducts.isNotEmpty) {
      return [
        _buildSectionTitle(sectionTitle),
        _buildHorizontalProductList(tagProducts.take(10).toList()),
      ];
    }
    
    // Không có sản phẩm thì trả về list rỗng
    return [];
  }
  
  // Phương thức để loại bỏ các sản phẩm trùng lặp
  List<ProductModel> _removeDuplicateProducts(List<ProductModel> products) {
    final Map<String, ProductModel> uniqueProducts = {};
    
    for (var product in products) {
      uniqueProducts[product.id] = product;
    }
    
    return uniqueProducts.values.toList();
  }
  
  // Phương thức để xây dựng các section theo loại sản phẩm
  List<Widget> _buildProductTypesSections(List<ProductModel> products, List<dynamic> productTypes) {
    // Nhóm sản phẩm theo loại sản phẩm
    final Map<String, Map<String, dynamic>> productsByType = {};
    
    // Nhóm sản phẩm theo productType.id
    for (var product in products) {
      if (product.productType.isNotEmpty) {
        final productType = product.productType;
        String? typeId;
        String typeName = "SẢN PHẨM KHÁC";
        
        try {
          if (productType.containsKey('id') && productType['id'] != null) {
            typeId = productType['id'].toString();
          }
        } catch (e) {
          developer.log("Lỗi khi lấy ID của loại sản phẩm: $e");
        }
        
        try {
          if (productType.containsKey('name') && productType['name'] != null) {
            typeName = productType['name'].toString();
          }
        } catch (e) {
          developer.log("Lỗi khi lấy tên loại sản phẩm: $e");
        }
        
        if (typeId != null && typeId.isNotEmpty) {
          if (!productsByType.containsKey(typeId)) {
            productsByType[typeId] = {
              'name': typeName,
              'products': <ProductModel>[]
            };
          }
          
          (productsByType[typeId]!['products'] as List<ProductModel>).add(product);
        }
      }
    }
    
    // Giới hạn số lượng sản phẩm trong mỗi loại và xây dựng các widget
    List<Widget> typeWidgets = [];
    for (var entry in productsByType.entries) {
      final typeName = entry.value['name'] as String;
      final typeProducts = entry.value['products'] as List<ProductModel>;
      
      if (typeProducts.isNotEmpty) {
        typeWidgets.add(_buildSectionTitle(typeName.toUpperCase()));
        typeWidgets.add(_buildHorizontalProductList(typeProducts.take(10).toList()));
      }
    }
    
    return typeWidgets;
  }

  Widget _buildEmptySection() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: const Text(
        'Không có sản phẩm nào',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Khuyến Mãi Đặc Biệt',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Giảm đến 20% cho tất cả sản phẩm công nghệ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Khám Phá Ngay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Xem tất cả',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(List<ProductModel> products) {
    final screenWidth = MediaQuery.of(context).size.width;
    double itemWidth;

    if (screenWidth < 600) { // Mobile
      itemWidth = (screenWidth / 2.2).clamp(150.0, 210.0); // Slightly wider items on mobile
    } else if (screenWidth < 960) { // Tablet Portrait
      itemWidth = (screenWidth / 3.2).clamp(160.0, 210.0);
    } else { // Tablet Landscape / Desktop-like
      itemWidth = (screenWidth / 4.5).clamp(170.0, 220.0);
    }

    // Estimate height based on itemWidth and a common aspect ratio for cards (e.g., width/height ~ 0.6 - 0.7 for portrait cards)
    // Height should be roughly itemWidth / 0.6 or itemWidth / 0.7. Let's use a factor.
    // Typical card might be around 160w x 250-280h.
    // If itemWidth is 180, height might be around 180 / (2/3) = 270, or 180 / 0.6 = 300
    double estimatedItemHeight = itemWidth / 0.75; // Adjusted for potential tags
    // if (estimatedItemHeight < 280) estimatedItemHeight = 280; // Min height
    // if (estimatedItemHeight > 340) estimatedItemHeight = 340; // Max height

    const double originalImageHeight = 120.0;
    double responsiveImageHeight = (originalImageHeight * (itemWidth / 160.0)).clamp(100.0, 160.0); // Adjusted clamp

    return SizedBox(
      height: estimatedItemHeight, // Use estimated height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(product, itemWidth, responsiveImageHeight);
        },
      ),
    );
  }

  Widget _buildProductItem(ProductModel product, double itemWidth, double imageHeight) {
    final actualPrice = product.price * (1 - (product.discountPercent / 100));
    
    final List<Map<String, dynamic>> activeTags = [];
    if (product.tags.isNotEmpty) {
      for (var tag in product.tags) {
        if (tag is Map<String, dynamic> && 
            tag.containsKey('active') && 
            tag['active'] == true &&
            tag.containsKey('name') &&
            tag.containsKey('id')) {
          activeTags.add(Map<String, dynamic>.from(tag));
        }
      }
    }
    
    return GestureDetector(
      onTap: () {
        NavigationHelper.navigateToProductDetail(context, product.id);
      },
      child: Container(
        width: itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: Image.network(
                    ImageHelper.getImage(product.primaryImageUrl),
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                if (product.discountPercent > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Tags Section
            if (activeTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 2.0),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ),
            
            // Product Info
            Padding(
              padding: EdgeInsets.only(
                left: 8.0, 
                right: 8.0, 
                bottom: 8.0, 
                top: activeTags.isEmpty ? 4.0 : 2.0
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (product.discountPercent > 0) ...[
                    Text(
                      '${_formatCurrency(actualPrice)} đ',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${_formatCurrency(product.price)} đ',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${_formatCurrency(product.price)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        product.averageRating == null 
                            ? 'N/A' 
                            : product.averageRating! > 0 ? product.averageRating!.toStringAsFixed(1) : '0.0',
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Đã bán ${product.soldCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Simple formatting: add a comma as thousands separator
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  // Hàm để chuyển đổi màu từ string sang Color
  Color _getTagColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.blue; // Màu mặc định
    }
    
    // Xử lý chuỗi màu hex
    if (colorString.startsWith('#')) {
      try {
        String hexColor = colorString.replaceAll('#', '');
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse(hexColor, radix: 16));
      } catch (e) {
        return Colors.blue; // Trả về màu mặc định nếu xử lý thất bại
      }
    }
    
    // Xử lý tên màu
    switch (colorString.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'yellow': return Colors.yellow;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'cyan': return Colors.cyan;
      case 'amber': return Colors.amber;
      case 'indigo': return Colors.indigo;
      case 'brown': return Colors.brown;
      case 'grey': return Colors.grey;
      case 'black': return Colors.black;
      default: return Colors.blue;
    }
  }
} 