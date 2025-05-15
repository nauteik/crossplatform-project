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
    return Message(
      id: map['id'],
      userId: map['userId'],
      adminId: map['adminId'],
      content: map['content'],
      images: List<String>.from(map['images'] ?? []),
      isFromUser: map['isFromUser'],
      isRead: map['isRead'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
} 