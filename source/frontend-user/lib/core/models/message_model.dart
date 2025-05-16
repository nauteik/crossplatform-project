import 'dart:convert';
import 'package:intl/intl.dart';

class Message {
  final String id;
  final String userId;
  final String adminId;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final bool isRead;
  final bool isFromUser;

  Message({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.isRead,
    required this.isFromUser,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'adminId': adminId,
      'content': content,
      'images': images,
      'createdAt': DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(createdAt),
      'read': isRead,
      'fromUser': isFromUser,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      adminId: map['adminId'] ?? '',
      content: map['content'] ?? '',
      images: map['images'] != null 
          ? List<String>.from(map['images']) 
          : [],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      isRead: map['read'] ?? false,
      isFromUser: map['fromUser'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));

  // Thêm phương thức copyWith
  Message copyWith({
    String? id,
    String? userId,
    String? adminId,
    String? content,
    List<String>? images,
    DateTime? createdAt,
    bool? isRead,
    bool? isFromUser,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isFromUser: isFromUser ?? this.isFromUser,
    );
  }
} 