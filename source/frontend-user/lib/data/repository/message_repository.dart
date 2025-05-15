import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api_constants.dart';
import '../../core/models/message_model.dart';

class MessageRepository {
  final String baseUrl = ApiConstants.baseUrl;

  // Lấy cuộc hội thoại giữa user và admin
  Future<List<Message>> getConversation(String userId, String adminId) async {
    final url = '$baseUrl/messages/conversation?userId=$userId&adminId=$adminId';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // Debug: In thông tin phản hồi để kiểm tra
      print('API Response: $responseData');
      
      // Kiểm tra nếu có status hoặc code
      if (responseData.containsKey('status') && responseData['status'] == 200) {
        final List<dynamic> messageData = responseData['data'];
        return messageData.map((data) => Message.fromMap(data)).toList();
      } else if (responseData.containsKey('code') && responseData['code'] == 'SUCCESS') {
        final List<dynamic> messageData = responseData['data'];
        return messageData.map((data) => Message.fromMap(data)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi tải tin nhắn');
      }
    } else {
      throw Exception('Failed to load conversation: ${response.statusCode}');
    }
  }
  
  // Gửi tin nhắn từ user đến admin (dùng cho mobile)
  Future<Message> sendMessage(String userId, String content, List<File>? images) async {
    var uri = Uri.parse('$baseUrl/messages/user-send');
    
    var request = http.MultipartRequest('POST', uri);
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
      
      // Kiểm tra cả hai loại phản hồi
      if ((responseData.containsKey('status') && responseData['status'] == 200) ||
          (responseData.containsKey('code') && responseData['code'] == 'SUCCESS')) {
        return Message.fromMap(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi gửi tin nhắn');
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
  
  // Gửi tin nhắn từ user đến admin (dùng cho web)
  Future<Message> sendMessageWithBytes(String userId, String content, List<ImageData>? images) async {
    var uri = Uri.parse('$baseUrl/messages/user-send');
    
    var request = http.MultipartRequest('POST', uri);
    request.fields['userId'] = userId;
    request.fields['content'] = content;
    
    if (images != null) {
      for (var imageData in images) {
        var multipartFile = http.MultipartFile.fromBytes(
          'images',
          imageData.bytes,
          filename: imageData.filename,
          contentType: MediaType('image', imageData.mimeType.split('/')[1]),
        );
        
        request.files.add(multipartFile);
      }
    }
    
    var response = await request.send();
    
    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = json.decode(responseBody);
      
      // Kiểm tra cả hai loại phản hồi
      if ((responseData.containsKey('status') && responseData['status'] == 200) ||
          (responseData.containsKey('code') && responseData['code'] == 'SUCCESS')) {
        return Message.fromMap(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi gửi tin nhắn');
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
  
  // Xóa tin nhắn
  Future<bool> deleteMessage(String messageId) async {
    final url = '$baseUrl/messages/delete/$messageId';
    
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData.containsKey('status') && responseData['status'] == 200 ||
             responseData.containsKey('code') && responseData['code'] == 'SUCCESS';
    } else {
      throw Exception('Failed to delete message: ${response.statusCode}');
    }
  }
  
  // Lấy ID admin mặc định
  Future<String> getDefaultAdminId() async {
    final url = '$baseUrl/user/default-admin';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // Kiểm tra cả hai loại phản hồi
      if ((responseData.containsKey('status') && responseData['status'] == 200) ||
          (responseData.containsKey('code') && responseData['code'] == 'SUCCESS')) {
        return responseData['data']['id'];
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi lấy ID admin');
      }
    } else {
      throw Exception('Failed to get default admin ID: ${response.statusCode}');
    }
  }
}

// Class để lưu trữ thông tin hình ảnh cho web
class ImageData {
  final Uint8List bytes;
  final String filename;
  final String mimeType;
  
  ImageData({required this.bytes, required this.filename, required this.mimeType});
} 