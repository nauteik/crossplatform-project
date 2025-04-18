import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_info.dart';
import '../widgets/product_specifications.dart';
import '../widgets/product_bottom_sheet.dart';
import '../../../../core/utils/navigation_helper.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final ValueNotifier<int> _selectedImageIndex = ValueNotifier<int>(0);
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    // Fetch product details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.getProductById(widget.productId);
      
      // Lấy danh sách ảnh từ product
      if (productProvider.currentProduct != null) {
        final product = productProvider.currentProduct!;
        setState(() {
          // Thêm primaryImageUrl vào đầu danh sách
          _images = [product.primaryImageUrl, ...product.imageUrls];
        });
      }
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _handleReviewTap() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      NavigationHelper.navigateToProductReview(context, widget.productId);
    } else {
      NavigationHelper.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Sản Phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Thêm vào danh sách yêu thích
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm vào danh sách yêu thích'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Chia sẻ sản phẩm
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép link sản phẩm'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final status = productProvider.status;
          final product = productProvider.currentProduct;

          if (status == ProductStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (status == ProductStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Có lỗi xảy ra: ${productProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.getProductById(widget.productId);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (product == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin sản phẩm'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images Gallery
                ProductGallery(
                  images: _images,
                  selectedImageIndex: _selectedImageIndex,
                ),

                // Product Info Section
                const SizedBox(height: 24),
                ProductInfo(
                  product: product,
                  quantity: _quantity,
                  onIncrementQuantity: _incrementQuantity,
                  onDecrementQuantity: _decrementQuantity,
                ),
                
                // Product details
                const SizedBox(height: 24),
                const Text(
                  'Mô Tả Sản Phẩm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                // Specifications
                const SizedBox(height: 24),
                ProductSpecifications(product: product),
                
                // Reviews section
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Đánh Giá Sản Phẩm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _handleReviewTap,
                      icon: const Icon(Icons.edit),
                      label: const Text('Viết đánh giá'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 48),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '4.8',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Dựa trên ${product.soldCount} đánh giá',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá sản phẩm này!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom spacing
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomSheet: ProductBottomSheet(
        onAddToCart: () {
          // Thêm vào giỏ hàng
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm vào giỏ hàng'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onBuyNow: () {
          // Mua ngay
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng mua ngay đang được phát triển'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
} 