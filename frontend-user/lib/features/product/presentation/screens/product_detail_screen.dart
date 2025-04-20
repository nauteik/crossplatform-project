import 'package:flutter/material.dart';
import 'package:frontend_user/data/model/api_response_model.dart';
import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/data/model/product_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/product_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_info.dart';
import '../widgets/product_specifications.dart';
import '../widgets/product_bottom_sheet.dart';
import '../widgets/review_item.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/review_model.dart';
import '../screens/product_reviews_screen.dart';

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
  bool _isLoadingReviews = true;
  Map<String, dynamic>? _reviewSummary;
  List<ReviewModel> _reviews = [];
  static const int _initialReviewCount = 3; // Hiển thị 3 đánh giá đầu tiên
  List<String> _images = [];
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    // Fetch product details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      await productProvider.getProductById(widget.productId);

      // Lấy danh sách ảnh từ product
      if (productProvider.currentProduct != null) {
        final product = productProvider.currentProduct!;
        setState(() {
          // Thêm primaryImageUrl vào đầu danh sách
          _images = [product.primaryImageUrl, ...product.imageUrls];
        });
      }
      _fetchReviewData();
    });
  }

  Future<void> _fetchReviewData() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      // Fetch review summary
      final summaryResponse = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/reviews/summary/${widget.productId}'),
      );

      if (summaryResponse.statusCode == 200) {
        final summaryData = json.decode(summaryResponse.body);
        setState(() {
          _reviewSummary = summaryData['data'];
        });
      }

      // Fetch reviews
      final reviewsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/reviews/${widget.productId}'),
      );

      if (reviewsResponse.statusCode == 200) {
        final reviewsData = json.decode(reviewsResponse.body);
        final List<dynamic> reviewsList = reviewsData['data'] ?? [];

        setState(() {
          _reviews = reviewsList
              .map((review) => ReviewModel.fromJson(review))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching review data: $e');
    } finally {
      setState(() {
        _isLoadingReviews = false;
      });
    }
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
      NavigationHelper.navigateToProductReview(context, widget.productId)
          .then((value) {
        // Refresh reviews when returning from review screen
        if (value == true) {
          _fetchReviewData();
        }
      });
    } else {
      NavigationHelper.navigateToLogin(context);
    }
  }

  void _navigateToAllReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductReviewsScreen(
          productId: widget.productId,
          reviews: _reviews,
          reviewSummary: _reviewSummary,
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
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
        imageUrl: productProvider.currentProduct!.primaryImageUrl,
        quantity: _quantity,
      );

      ApiResponse<dynamic> response = await cartProvider.addItem(cartItem);
      print(response.message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.status == 1 ? Colors.green : Colors.red,
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

                // Review summary card
                _buildReviewSummaryCard(),

                // Review list
                if (_reviews.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ..._reviews
                      .take(_initialReviewCount)
                      .map((review) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ReviewItem(
                              review: review,
                              onDeleted: _fetchReviewData,
                            ),
                          ))
                      .toList(),

                  // "Xem thêm" button if there are more reviews
                  if (_reviews.length > _initialReviewCount)
                    Center(
                      child: TextButton(
                        onPressed: _navigateToAllReviews,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Xem tất cả ${_reviews.length} đánh giá',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],

                // Bottom spacing
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomSheet: ProductBottomSheet(
        onAddToCart: _handleAddToCart,
        isLoadingAddToCart: _isAddingToCart,
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

  Widget _buildReviewSummaryCard() {
    if (_isLoadingReviews) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_reviewSummary == null || (_reviewSummary?['totalReviews'] ?? 0) == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_border, color: Colors.amber, size: 48),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Chưa có đánh giá',
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
      );
    }

    final averageRating = _reviewSummary!['averageRating'];
    final totalReviews = _reviewSummary!['totalReviews'];
    final ratingDistribution =
        _reviewSummary!['ratingDistribution'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Average rating overview
            Row(
              children: [
                // Left side - big rating number
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalReviews đánh giá',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side - rating bars
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((rating) {
                      final count = ratingDistribution[rating.toString()] ?? 0;
                      final percentage =
                          totalReviews > 0 ? (count / totalReviews) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$rating',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.amber,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
