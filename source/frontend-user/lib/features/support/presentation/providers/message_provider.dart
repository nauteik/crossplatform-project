import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/message_model.dart';
import '../../../../data/repository/message_repository.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _repository = MessageRepository();
  
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _adminId;
  String? _errorMessage;
  
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get adminId => _adminId;
  String? get errorMessage => _errorMessage;
  
  // Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Lấy ID admin mặc định từ server
  Future<void> fetchDefaultAdminId() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final adminId = await _repository.getDefaultAdminId();
      _adminId = adminId;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể kết nối với hỗ trợ viên: ${e.toString()}';
      notifyListeners();
    }
  }
  
  void setAdminId(String adminId) {
    _adminId = adminId;
    notifyListeners();
  }
  
  Future<void> loadConversation(String userId, String adminId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _messages = await _repository.getConversation(userId, adminId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải tin nhắn: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Gửi tin nhắn với File (dùng cho mobile)
  Future<void> sendMessage(String userId, String content, List<File>? images) async {
    _errorMessage = null;
    try {
      if (kIsWeb) {
        throw Exception("Hãy sử dụng sendWebMessage cho web");
      }
      
      final message = await _repository.sendMessage(userId, content, images);
      _messages.insert(0, message);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể gửi tin nhắn: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Gửi tin nhắn với Bytes (dùng cho web)
  Future<void> sendWebMessage(String userId, String content, List<XFile>? images) async {
    _errorMessage = null;
    try {
      if (!kIsWeb) {
        throw Exception("Hãy sử dụng sendMessage cho mobile");
      }
      
      List<ImageData>? imageDataList;
      if (images != null && images.isNotEmpty) {
        imageDataList = [];
        for (var image in images) {
          // Đọc dữ liệu hình ảnh
          final bytes = await image.readAsBytes();
          
          // Lấy tên file và định dạng
          final filename = image.name;
          final mimeType = image.mimeType ?? 'image/jpeg';
          
          imageDataList.add(ImageData(
            bytes: bytes, 
            filename: filename,
            mimeType: mimeType
          ));
        }
      }
      
      final message = await _repository.sendMessageWithBytes(userId, content, imageDataList);
      _messages.insert(0, message);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể gửi tin nhắn: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> deleteMessage(String messageId) async {
    _errorMessage = null;
    try {
      final success = await _repository.deleteMessage(messageId);
      if (success) {
        _messages.removeWhere((message) => message.id == messageId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Không thể xóa tin nhắn: ${e.toString()}';
      notifyListeners();
    }
  }
} 