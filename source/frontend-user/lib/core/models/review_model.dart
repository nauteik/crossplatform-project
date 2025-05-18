class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String comment;
  final List<MediaModel> media;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.media,
    required this.createdAt,
  });

  // Sửa phương thức fromJson để xử lý media
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final List<MediaModel> mediaList = [];

    if (json['media'] != null) {
      for (var item in json['media']) {
        mediaList.add(MediaModel.fromJson(item));
      }
    }

    return ReviewModel(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      media: mediaList,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class MediaModel {
  final String url;
  final String type; // image or video

  MediaModel({
    required this.url,
    required this.type,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
    );
  }
}
