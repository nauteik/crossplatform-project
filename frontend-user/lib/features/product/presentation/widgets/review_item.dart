import 'package:flutter/material.dart';
import '../../../../core/models/review_model.dart';
import '../../../../core/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import 'dart:math' as Math;

class ReviewItem extends StatelessWidget {
  final ReviewModel review;
  final bool showFullContent;
  final Function()? onDeleted;

  const ReviewItem({
    super.key, 
    required this.review,
    this.showFullContent = false,
    this.onDeleted,
  });

  Future<void> _deleteReview(BuildContext context) async {
    final currentUserId = AuthService.getCurrentUserId();
    
    if (currentUserId == null || currentUserId != review.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không có quyền xóa đánh giá này')),
      );
      return;
    }
    
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    
    if (confirm != true) return;
    
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/reviews/${review.id}/$currentUserId'),
      );
      
      if (response.statusCode == 200) {
        // Gọi callback để cập nhật UI sau khi xóa
        if (onDeleted != null) {
          onDeleted!();
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa đánh giá thành công')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể xóa đánh giá')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final date = DateTime.parse(review.createdAt);
    final formattedDate = "${date.day}/${date.month}/${date.year}";
    
    // Check if current user is the author of this review
    final currentUserId = AuthService.getCurrentUserId();
    final isAuthor = currentUserId != null && currentUserId == review.userId;
    
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    review.userId.isNotEmpty 
                        ? review.userId[0].toUpperCase() 
                        : '?',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Username and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Người dùng ${review.userId.substring(0, Math.min(5, review.userId.length))}...',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                
                // Delete button for review author
                if (isAuthor)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _deleteReview(context),
                    tooltip: 'Xóa đánh giá',
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            
            // Comment
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: const TextStyle(fontSize: 14),
                maxLines: showFullContent ? null : 3,
                overflow: showFullContent ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ],
            
            // Media preview
            if (review.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.media.length,
                  itemBuilder: (context, index) {
                    final media = review.media[index];
                    // Check if it's an image or video based on type
                    final isVideo = media.type == 'video';
                    
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                        image: isVideo 
                            ? null 
                            : DecorationImage(
                                image: NetworkImage(media.url),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: isVideo 
                          ? const Center(
                              child: Icon(Icons.play_circle, size: 32, color: Colors.white),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
