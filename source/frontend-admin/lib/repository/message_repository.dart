import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/config/api_config.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class MessageRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Lấy cuộc hội thoại giữa admin và user
  Future<List<Message>> getConversation(String userId, String adminId) async {
    final url = '$baseUrl/api/messages/conversation?userId=$userId&adminId=$adminId';
    print('Fetching conversation: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('Conversation response status: ${response.statusCode}');
    print('Conversation response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 200) {
        final List<dynamic> messageData = responseData['data'];
        print('Message data: $messageData');
        return messageData.map((data) => Message.fromMap(data)).toList();
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to load conversation');
    }
  }
  
  // Lấy danh sách users đã gửi tin nhắn cho admin
  Future<List<User>> getUsersWithMessages(String adminId) async {
    final url = '$baseUrl/api/messages/admin/$adminId/users';
    print('Đang tải danh sách người dùng từ: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('API getUsersWithMessages response code: ${response.statusCode}');
      
      // In ra một phần của nội dung phản hồi (nếu quá dài)
      final responseBody = response.body;
      final previewLength = responseBody.length > 300 ? 300 : responseBody.length;
      print('API getUsersWithMessages preview: ${responseBody.substring(0, previewLength)}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 200 && responseData['data'] != null) {
          final List<dynamic> userData = responseData['data'];
          return userData.map((data) => User.fromJson(data)).toList();
        } else {
          print('API getUsersWithMessages lỗi status: ${responseData['status']}, message: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Lỗi khi tải danh sách người dùng');
        }
      } else {
        print('API getUsersWithMessages lỗi HTTP: ${response.statusCode}');
        throw Exception('Lỗi khi kết nối tới máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi tải danh sách người dùng: $e');
      rethrow;
    }
  }
  
  // Gửi tin nhắn từ admin đến user
  Future<Message> sendMessage(String adminId, String userId, String content, List<File>? images) async {
    var uri = Uri.parse('$baseUrl/api/messages/admin-send');
    
    var request = http.MultipartRequest('POST', uri);
    request.fields['adminId'] = adminId;
    request.fields['userId'] = userId;
    request.fields['content'] = content;
    
    if (images != null) {
      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        
        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        
        request.files.add(multipartFile);
      }
    }
    
    var response = await request.send();
    
    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = json.decode(responseBody);
      if (responseData['status'] == 200) {
        return Message.fromMap(responseData['data']);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to send message');
    }
  }
  
  // Đánh dấu tin nhắn đã đọc
  Future<void> markMessagesAsRead(String userId, String adminId) async {
    final url = '$baseUrl/api/messages/mark-read';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'userId': userId,
        'adminId': adminId,
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to mark messages as read');
    }
  }
  
  // Đếm số lượng tin nhắn chưa đọc
  Future<int> countUnreadMessages() async {
    final url = '$baseUrl/api/messages/unread-count';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 200) {
        return responseData['data']['count'] as int;
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to count unread messages');
    }
  }
  
  // Xóa tin nhắn
  Future<bool> deleteMessage(String messageId) async {
    final url = '$baseUrl/api/messages/delete/$messageId';
    
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['status'] == 200;
    } else {
      throw Exception('Failed to delete message');
    }
  }
} 