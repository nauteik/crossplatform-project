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
    // Debugging
    print('Received message data: $map');
    try {
      // Xử lý ID
      String? id = map['_id'] ?? map['id'];
      
      // Xử lý userID và adminID
      String userId = map['userId'] ?? '';
      String adminId = map['adminId'] ?? '';
      
      // Xử lý nội dung
      String content = map['content'] ?? '';
      
      // Xử lý danh sách ảnh
      List<String> imagesList = [];
      if (map['images'] != null) {
        if (map['images'] is List) {
          imagesList = List<String>.from(map['images']);
        } else if (map['images'] is String) {
          // Trường hợp images là một chuỗi JSON
          try {
            final decoded = json.decode(map['images']);
            if (decoded is List) {
              imagesList = List<String>.from(decoded);
            }
          } catch (e) {
            print('Error parsing images: $e');
          }
        }
      }
      
      // Xử lý isFromUser - kiểm tra cả fromUser và isFromUser
      bool isFromUser = false;
      if (map.containsKey('isFromUser')) {
        isFromUser = map['isFromUser'] ?? false;
      } else if (map.containsKey('fromUser')) {
        isFromUser = map['fromUser'] ?? false;
      }
      
      // Xử lý isRead - kiểm tra cả read và isRead
      bool isRead = false;
      if (map.containsKey('isRead')) {
        isRead = map['isRead'] ?? false;
      } else if (map.containsKey('read')) {
        isRead = map['read'] ?? false;
      }
      
      // Xử lý createdAt từ các định dạng khác nhau
      DateTime createdAt;
      if (map['createdAt'] is String) {
        try {
          createdAt = DateTime.parse(map['createdAt']);
        } catch (e) {
          print('Error parsing createdAt: $e, using current datetime');
          createdAt = DateTime.now();
        }
      } else if (map.containsKey('_date') && map['_date'] is String) {
        try {
          createdAt = DateTime.parse(map['_date']);
        } catch (e) {
          print('Error parsing _date: $e, using current datetime');
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }
      
      return Message(
        id: id,
        userId: userId,
        adminId: adminId,
        content: content,
        images: imagesList,
        isFromUser: isFromUser,
        isRead: isRead,
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error creating Message from map: $e');
      print('Map data: $map');
      // Trả về message mặc định thay vì ném lỗi
      return Message(
        id: null,
        userId: '',
        adminId: '',
        content: 'Error: Unable to parse message',
        images: [],
        isFromUser: false,
        isRead: false,
        createdAt: DateTime.now(),
      );
    }
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
  
  Message copyWith({
    String? id,
    String? userId,
    String? adminId,
    String? content,
    List<String>? images,
    bool? isFromUser,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      content: content ?? this.content,
      images: images ?? this.images,
      isFromUser: isFromUser ?? this.isFromUser,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 