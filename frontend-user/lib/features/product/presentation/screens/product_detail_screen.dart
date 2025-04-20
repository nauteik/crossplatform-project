import 'package:flutter/material.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/data/model/product_model.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_info.dart';
import '../widgets/product_specifications.dart';
import '../widgets/product_bottom_sheet.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../cart/providers/cart_provider.dart';

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
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    // Fetch product details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .getProductById(widget.productId);
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

  Future<void> _handleAddToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      NavigationHelper.navigateToLogin(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (productProvider.currentProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thông tin sản phẩm chưa được tải xong.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isAddingToCart) return;
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartItem = CartItemModel(
        id: productProvider.currentProduct!.id,
        name: productProvider.currentProduct!.name,
        price: productProvider.currentProduct!.price,
        imageUrl: productProvider.currentProduct!.imageUrl,
        quantity: _quantity,
      );

      cartProvider.addItem(cartItem, authProvider.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm sản phẩm vào giỏ hàng!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _quantity = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }

    // // 1. Kiểm tra đăng nhập
    // if (!authProvider.isAuthenticated) {
    //   NavigationHelper.navigateToLogin(context);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.'),
    //       backgroundColor: Colors.orange,
    //     ),
    //   );
    //   return;
    // }

    // // 2. Kiểm tra sản phẩm đã load chưa
    // if (productProvider.currentProduct == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Thông tin sản phẩm chưa được tải xong.'),
    //       backgroundColor: Colors.orange,
    //     ),
    //   );
    //   return;
    // }

    // // 3. Tránh việc nhấn nút nhiều lần
    // if (_isAddingToCart) return;
    // setState(() {
    //   _isAddingToCart = true;
    // });

    // try {
    //   // 4. Tạo product model
    //   final product = ProductModel(
    //     id: productProvider.currentProduct!.id,
    //     name: productProvider.currentProduct!.name,
    //     price: productProvider.currentProduct!.price,
    //     imageUrl: productProvider.currentProduct!.imageUrl,
    //     quantity: _quantity,
    //   );

    //   // 5. Thêm vào giỏ hàng sử dụng CartProvider
    //   cartProvider.addItem(product);
      
    //   // 6. Hiển thị thông báo thành công
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Đã thêm sản phẩm vào giỏ hàng!'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );

    //   // Reset số lượng về 1
    //   setState(() {
    //     _quantity = 1;
    //   });
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Đã xảy ra lỗi: ${e.toString()}'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // } finally {
    //   // 7. Reset trạng thái loading
    //   setState(() {
    //     _isAddingToCart = false;
    //   });
    // }
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

          // Mock data for demo purposes
          final List<String> images = [
            product.imageUrl,
            'https://picsum.photos/500/500?random=1',
            'https://picsum.photos/500/500?random=2',
            'https://picsum.photos/500/500?random=3',
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images Gallery
                ProductGallery(
                  images: images,
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
                            const Icon(Icons.star,
                                color: Colors.amber, size: 48),
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
        // Pass the loading state down
        isLoadingAddToCart: _isAddingToCart,
        onAddToCart: _handleAddToCart, // Use the new handler method
        onBuyNow: () {
          // Mua ngay - Keep existing logic for now
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
