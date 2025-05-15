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
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
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
    // Sắp xếp sản phẩm dựa trên tags từ backend thay vì logic frontend
    
    // 1. Tìm sản phẩm theo tag "Khuyến mãi"
    final promotionalProducts = products
        .where((product) => product.tags.isNotEmpty && 
            product.tags.any((tag) => tag is Map<String, dynamic> && 
                tag.containsKey('name') && tag['name'] == 'Khuyến mãi'))
        .toList();
        
    // 2. Tìm sản phẩm theo tag "Bán chạy"
    final bestSellerProducts = products
        .where((product) => product.tags.isNotEmpty && 
            product.tags.any((tag) => tag is Map<String, dynamic> && 
                tag.containsKey('name') && tag['name'] == 'Bán chạy'))
        .toList();
    
    // 3. Tìm sản phẩm theo tag "Mới"
    final latestProducts = products
        .where((product) => product.tags.isNotEmpty && 
            product.tags.any((tag) => tag is Map<String, dynamic> && 
                tag.containsKey('name') && tag['name'] == 'Mới'))
        .toList();
    
    // Dự phòng: Nếu không có sản phẩm nào có tag "Khuyến mãi", lấy các sản phẩm có discountPercent > 0
    if (promotionalProducts.isEmpty) {
      promotionalProducts.addAll(
        products.where((p) => p.discountPercent > 0).take(10).toList()
      );
    }
    
    // Dự phòng: Nếu không có sản phẩm nào có tag "Bán chạy", sắp xếp theo soldCount
    if (bestSellerProducts.isEmpty) {
      bestSellerProducts.addAll(
        products.where((p) => p.soldCount > 150).toList()
          ..sort((a, b) => b.soldCount.compareTo(a.soldCount))
      );
    }
    
    // Dự phòng: Nếu không có sản phẩm nào có tag "Mới", sắp xếp theo createdAt
    if (latestProducts.isEmpty) {
      latestProducts.addAll(
        List.of(products)..sort((a, b) {
          final aCreatedAt = a.createdAt ?? 0;
          final bCreatedAt = b.createdAt ?? 0;
          return bCreatedAt.compareTo(aCreatedAt);
        })
      );
    }
    
    // Giới hạn số lượng sản phẩm trong mỗi danh mục
    final limitedPromotionalProducts = promotionalProducts.take(10).toList();
    final limitedBestSellerProducts = bestSellerProducts.take(10).toList();
    final limitedLatestProducts = latestProducts.take(10).toList();

    // Debug: In thông tin về productTypes để kiểm tra cấu trúc
    developer.log("ProductTypes: ${productTypes.length}");
    for (var i = 0; i < productTypes.length; i++) {
      developer.log("ProductType $i: ${productTypes[i]}");
    }
    
    // Nhóm sản phẩm theo loại sản phẩm (product types)
    final Map<String, Map<String, dynamic>> productsByType = {};
    
    // Đầu tiên, nhóm sản phẩm theo productType.id và lưu luôn thông tin tên
    for (var product in products) {
      if (product.productType.isNotEmpty) {
        // Lấy thông tin productType từ sản phẩm
        final productType = product.productType;
        String? typeId;
        String typeName = "SẢN PHẨM KHÁC";
        
        // Xử lý an toàn khi lấy ID của loại sản phẩm
        try {
          if (productType.containsKey('id') && productType['id'] != null) {
            typeId = productType['id'].toString();
          }
        } catch (e) {
          developer.log("Lỗi khi lấy ID của loại sản phẩm: $e");
        }
        
        // Xử lý an toàn khi lấy tên loại sản phẩm
        try {
          if (productType.containsKey('name') && productType['name'] != null) {
            typeName = productType['name'].toString();
            developer.log("Tên loại sản phẩm: $typeName");
          }
        } catch (e) {
          developer.log("Lỗi khi lấy tên loại sản phẩm: $e");
        }
        
        // Chỉ xử lý nếu có ID hợp lệ
        if (typeId != null && typeId.isNotEmpty) {
          if (!productsByType.containsKey(typeId)) {
            productsByType[typeId] = {
              'name': typeName,
              'products': <ProductModel>[]
            };
          }
          
          // Thêm sản phẩm vào danh sách tương ứng với typeId
          (productsByType[typeId]!['products'] as List<ProductModel>).add(product);
        }
      }
    }
    
    // Debug thông tin loại sản phẩm đã nhóm
    developer.log("Grouped product types: ${productsByType.length}");
    for (var entry in productsByType.entries) {
      developer.log("Type ID: ${entry.key}, Name: ${entry.value['name']}, Products: ${(entry.value['products'] as List).length}");
    }
    
    // Giới hạn số lượng sản phẩm trong mỗi loại còn 10
    final limitedProductsByType = <String, Map<String, dynamic>>{};
    for (var entry in productsByType.entries) {
      final typeId = entry.key;
      final typeName = entry.value['name'] as String;
      final typeProducts = entry.value['products'] as List<ProductModel>;
      
      limitedProductsByType[typeId] = {
        'name': typeName,
        'products': typeProducts.take(10).toList()
      };
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          // Promotional Banner
          _buildPromotionalBanner(),
          
          // Promotional Products Section
          _buildSectionTitle('SẢN PHẨM KHUYẾN MÃI'),
          limitedPromotionalProducts.isEmpty 
              ? _buildEmptySection() 
              : _buildHorizontalProductList(limitedPromotionalProducts),
          
          // Best Seller Products Section
          _buildSectionTitle('SẢN PHẨM BÁN CHẠY'),
          limitedBestSellerProducts.isEmpty 
              ? _buildEmptySection() 
              : _buildHorizontalProductList(limitedBestSellerProducts),
          
          // New Products Section
          _buildSectionTitle('SẢN PHẨM MỚI'),
          limitedLatestProducts.isEmpty 
              ? _buildEmptySection() 
              : _buildHorizontalProductList(limitedLatestProducts),
          
          // Hiển thị sản phẩm theo từng loại
          ...limitedProductsByType.entries.map((entry) {
            final typeName = entry.value['name'] as String;
            final typeProducts = entry.value['products'] as List<ProductModel>;
            
            // In ra tên loại sản phẩm để debug
            developer.log("Displaying product type: $typeName with ${typeProducts.length} products");
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(typeName.toUpperCase()),
                typeProducts.isEmpty
                    ? _buildEmptySection()
                    : _buildHorizontalProductList(typeProducts),
              ],
            );
          }).toList(),
          
          const SizedBox(height: 30),
        ],
      ),
    );
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
      itemWidth = (screenWidth / 2.8).clamp(180.0, 200.0);
    } else if (screenWidth < 960) { // Tablet Portrait
      itemWidth = (screenWidth / 2.8).clamp(180.0, 200.0);
    } else { // Tablet Landscape / Desktop-like
      itemWidth = (screenWidth / 2.8).clamp(180.0, 200.0);
    }

    const double originalItemWidth = 160.0; // Reference for scaling
    const double originalListHeight = 200.0;
    const double originalImageHeight = 120.0;

    double scaleFactor = itemWidth / originalItemWidth;

    double responsiveListHeight = (originalListHeight * scaleFactor).clamp(200.0, 320.0);
    double responsiveImageHeight = (originalImageHeight * scaleFactor).clamp(110.0, 180.0);

    return SizedBox(
      height: responsiveListHeight,
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
    // Calculate the actual price after discount
    final actualPrice = product.price * (1 - (product.discountPercent / 100));
    
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
            // Product Image with Discount Badge (không hiển thị tag badge)
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
                // Chỉ hiển thị discount badge
                if (product.discountPercent > 0)
                  Positioned(
                    top: 8,
                    right: 8,
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
            
            // Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                      const Icon(Icons.shopping_cart, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
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
} 