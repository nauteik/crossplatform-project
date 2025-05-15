import 'dart:convert';

class Message {
  final String? id;
  final String userId;
  final String adminId;
  final String content;
  final List<String> images;
  final bool isFromUser;
  final bool isRead;
  final DateTime createdAt;

  Message({
    this.id,
    required this.userId,
    required this.adminId,
    required this.content,
    required this.images,
    required this.isFromUser,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'adminId': adminId,
      'content': content,
      'images': images,
      'isFromUser': isFromUser,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    // Xử lý trường hợp boolean bị chuyển về String "true"/"false"
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is num) return value != 0;
      return false;
    }
    
    try {
      return Message(
        id: map['id'],
        userId: map['userId'] ?? '',
        adminId: map['adminId'] ?? '',
        content: map['content'] ?? '',
        images: List<String>.from(map['images'] ?? []),
        isFromUser: parseBool(map['isFromUser']),
        isRead: parseBool(map['isRead']),
        createdAt: map['createdAt'] is String 
            ? DateTime.parse(map['createdAt']) 
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Message: $e');
      print('Original map: $map');
      // Trả về một message mặc định nếu có lỗi
      return Message(
        id: 'error',
        userId: '',
        adminId: '',
        content: 'Lỗi khi hiển thị tin nhắn',
        images: [],
        isFromUser: false,
        isRead: false,
        createdAt: DateTime.now(),
      );
    }
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
} 