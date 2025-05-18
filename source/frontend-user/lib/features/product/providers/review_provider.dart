import 'package:flutter/material.dart';
import '../../../data/respository/review_repository.dart';
import 'dart:developer' as developer;

enum ReviewStatus { initial, loading, loaded, error }

class ReviewProvider with ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository();

  Map<String, dynamic>? _reviewSummary;
  List<dynamic> _reviews = [];
  Map<String, Map<String, dynamic>?> _reviewSummaryCache = {};
  ReviewStatus _status = ReviewStatus.initial;
  String _errorMessage = '';

  // Getters
  Map<String, dynamic>? get reviewSummary => _reviewSummary;
  List<dynamic> get reviews => _reviews;
  ReviewStatus get status => _status;
  String get errorMessage => _errorMessage;

  // Lấy tổng kết đánh giá cho một sản phẩm
  Future<void> getReviewSummary(String productId) async {
    // Kiểm tra cache trước
    if (_reviewSummaryCache.containsKey(productId) && _reviewSummaryCache[productId] != null) {
      _reviewSummary = _reviewSummaryCache[productId];
      _status = ReviewStatus.loaded;
      notifyListeners();
      return;
    }

    _status = ReviewStatus.loading;
    notifyListeners();

    try {
      final response = await _repository.getReviewSummary(productId);

      // Kiểm tra kết quả API
      if (response.status > 0 && response.data != null) {
        _reviewSummary = response.data;
        _reviewSummaryCache[productId] = response.data;
        _status = ReviewStatus.loaded;
        developer.log("Loaded review summary for product $productId: ${response.data!['averageRating']}");
      } else {
        // Trong trường hợp không tìm thấy review hoặc có lỗi từ API nhưng vẫn trả về response
        _reviewSummary = {
          'averageRating': 0.0,
          'totalReviews': 0,
          'productId': productId,
          'ratingDistribution': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0}
        };
        _reviewSummaryCache[productId] = _reviewSummary;
        _status = ReviewStatus.loaded;
        developer.log("No reviews found for product $productId. Using default summary.");
      }
    } catch (e) {
      // Trong trường hợp lỗi, cũng tạo giá trị mặc định
      _reviewSummary = {
        'averageRating': 0.0,
        'totalReviews': 0,
        'productId': productId,
        'ratingDistribution': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0}
      };
      _reviewSummaryCache[productId] = _reviewSummary;
      _status = ReviewStatus.error;
      _errorMessage = e.toString();
      developer.log("Error fetching review summary: $e. Using default summary.");
    }

    notifyListeners();
  }

  // Lấy đánh giá cho một sản phẩm
  Future<void> getProductReviews(String productId) async {
    _status = ReviewStatus.loading;
    notifyListeners();

    try {
      final response = await _repository.getProductReviews(productId);

      if (response.status > 0 && response.data != null) {
        _reviews = response.data!;
        _status = ReviewStatus.loaded;
        developer.log("Loaded ${_reviews.length} reviews for product $productId");
      } else {
        _reviews = [];
        _status = ReviewStatus.loaded;
        developer.log("No reviews found for product $productId. Using empty list.");
      }
    } catch (e) {
      _reviews = [];
      _status = ReviewStatus.error;
      _errorMessage = e.toString();
      developer.log("Error fetching product reviews: $e. Using empty list.");
    }

    notifyListeners();
  }

  // Xóa cache để buộc refresh dữ liệu
  void clearCache() {
    _reviewSummaryCache.clear();
    notifyListeners();
  }

  // Lấy giá trị rating trung bình cho hiển thị
  double getAverageRating(String productId) {
    // Nếu có trong cache hoặc đã tải, trả về giá trị
    if (_reviewSummaryCache.containsKey(productId) && 
        _reviewSummaryCache[productId] != null &&
        _reviewSummaryCache[productId]!.containsKey('averageRating')) {
      return (_reviewSummaryCache[productId]!['averageRating'] as num).toDouble();
    }
    
    // Nếu không có, trả về giá trị mặc định là 0
    return 0.0;
  }
} 