import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/models/review_model.dart';
import '../widgets/review_item.dart';
import '../../../../core/constants/api_constants.dart';
import 'dart:math' as Math;

class ProductReviewsScreen extends StatefulWidget {
  final String productId;
  final List<ReviewModel> reviews;
  final Map<String, dynamic>? reviewSummary;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
    required this.reviews,
    this.reviewSummary,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  int _selectedRatingFilter = 0; // 0 means all ratings
  List<ReviewModel> _filteredReviews = [];
  List<ReviewModel> reviews = [];
  Map<String, dynamic>? reviewSummary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    reviews = widget.reviews;
    reviewSummary = widget.reviewSummary;
    _filteredReviews = reviews;
  }

  void _applyFilter(int rating) {
    setState(() {
      _selectedRatingFilter = rating;
      if (rating == 0) {
        _filteredReviews = reviews;
      } else {
        _filteredReviews =
            reviews.where((review) => review.rating == rating).toList();
      }
    });
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch reviews
      final reviewsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/reviews/${widget.productId}'),
      );

      if (reviewsResponse.statusCode == 200) {
        final reviewsData = json.decode(reviewsResponse.body);
        final List<dynamic> reviewsList = reviewsData['data'] ?? [];

        // Fetch review summary
        final summaryResponse = await http.get(
          Uri.parse(
              '${ApiConstants.baseUrl}/reviews/summary/${widget.productId}'),
        );

        Map<String, dynamic>? summaryData;
        if (summaryResponse.statusCode == 200) {
          final responseData = json.decode(summaryResponse.body);
          summaryData = responseData['data'];
        }

        setState(() {
          reviews = reviewsList
              .map((review) => ReviewModel.fromJson(review))
              .toList();
          reviewSummary = summaryData;

          // Re-apply current filter
          if (_selectedRatingFilter == 0) {
            _filteredReviews = reviews;
          } else {
            _filteredReviews = reviews
                .where((review) => review.rating == _selectedRatingFilter)
                .toList();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error refreshing reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReviews = reviews.isNotEmpty;
    final averageRating = reviewSummary?['averageRating'] ?? 0.0;
    final totalReviews = reviewSummary?['totalReviews'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất Cả Đánh Giá'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Rating summary
                if (hasReviews)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalReviews đánh giá',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                // Filter bar
                if (hasReviews)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(0, 'Tất cả'),
                        ...List.generate(5, (index) {
                          final rating = 5 - index;
                          return _buildFilterChip(rating, '$rating sao');
                        }),
                      ],
                    ),
                  ),

                // Reviews list
                Expanded(
                  child: hasReviews
                      ? _filteredReviews.isNotEmpty
                          ? ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredReviews.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                return ReviewItem(
                                  review: _filteredReviews[index],
                                  showFullContent: true,
                                  onDeleted: _refreshReviews,
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'Không có đánh giá ${_selectedRatingFilter} sao',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                      : const Center(
                          child: Text('Chưa có đánh giá nào'),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(int rating, String label) {
    final isSelected = _selectedRatingFilter == rating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _applyFilter(rating),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        showCheckmark: false,
      ),
    );
  }
}
