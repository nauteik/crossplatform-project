import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/message_model.dart';
import '../../../../data/repository/message_repository.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../auth/providers/auth_provider.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _repository = MessageRepository();
  final WebSocketService _webSocketService = WebSocketService();
  final AuthProvider authProvider;
  
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _adminId;
  String? _errorMessage;
  String? _currentUserId;
  
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get adminId => _adminId;
  String? get errorMessage => _errorMessage;
  
  MessageProvider(this.authProvider) {
    _currentUserId = authProvider.userId;
    authProvider.addListener(_updateUserIdFromAuthProvider);
    fetchDefaultAdminId().then((_) {
      if (_currentUserId != null && _adminId != null) {
        loadConversation(_currentUserId!, _adminId!);
      }
    });
  }
  
  void _updateUserIdFromAuthProvider() {
    if (_currentUserId != authProvider.userId) {
      _currentUserId = authProvider.userId;
      print("User MessageProvider: User ID updated from AuthProvider: $_currentUserId");
      if (_currentUserId != null && _adminId != null) {
        loadConversation(_currentUserId!, _adminId!);
      } else if (_currentUserId != null && _adminId == null) {
        fetchDefaultAdminId().then((_) {
          if (_adminId != null) loadConversation(_currentUserId!, _adminId!);
        });
      }
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<void> fetchDefaultAdminId() async {
    if (_adminId != null) return;
    _isLoading = true;
    _errorMessage = null;
    
    try {
      final fetchedAdminId = await _repository.getDefaultAdminId();
      _adminId = fetchedAdminId;
      print("User MessageProvider: Fetched Admin ID: $_adminId");
      _isLoading = false;
      if (_currentUserId != null && _adminId != null) {
        loadConversation(_currentUserId!, _adminId!); 
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể kết nối với hỗ trợ viên: ${e.toString()}';
      notifyListeners();
    }
  }
  
  void setAdminId(String adminId) {
    if (_adminId != adminId) {
      _adminId = adminId;
      if (_currentUserId != null) {
         loadConversation(_currentUserId!, _adminId!);
      }
      notifyListeners();
    }
  }
  
  Future<void> loadConversation(String userId, String adminId) async {
    if (userId.isEmpty || adminId.isEmpty) {
      _errorMessage = "User ID hoặc Admin ID không hợp lệ.";
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print("User MessageProvider: Loading conversation for user $userId and admin $adminId");
      _messages = await _repository.getConversation(userId, adminId);
      _isLoading = false;
      
      _connectWebSocket(userId, adminId);
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải tin nhắn: ${e.toString()}';
      print("User MessageProvider: Error loading conversation - $e");
      notifyListeners();
    }
  }
  
  void _connectWebSocket(String userId, String adminId) {
    final String? token = authProvider.token;

    if (token == null || token.isEmpty) {
      print('User MessageProvider: Lỗi - Không có token xác thực. Không thể kết nối WebSocket.');
      _errorMessage = "Vui lòng đăng nhập lại để sử dụng tính năng chat.";
      notifyListeners();
      return;
    }
    if (userId.isEmpty || adminId.isEmpty) {
      print('User MessageProvider: Lỗi - User ID hoặc Admin ID rỗng. Không thể kết nối WebSocket.');
      return;
    }

    try {
      print('User MessageProvider: Attempting to connect WebSocket for user $userId, admin $adminId.');
      _webSocketService.connect(token: token);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_webSocketService.isConnected) {
          print('User MessageProvider: WebSocket connected. Subscribing to topics.');
          _webSocketService.subscribeToUserMessages(userId, adminId, _handleNewMessage);
          _webSocketService.subscribeToMessageRead(userId, adminId, _handleMessageRead);
          _webSocketService.subscribeToMessageDeleted(userId, adminId, _handleMessageDeleted);
          print('User MessageProvider: Subscriptions completed for user $userId, admin $adminId.');
        } else {
          print('User MessageProvider: WebSocket failed to connect. Subscriptions skipped.');
           _errorMessage = "Không thể kết nối tới máy chủ chat. Vui lòng thử lại sau.";
           notifyListeners();
        }
      });

    } catch (e) {
      print('User MessageProvider: Error connecting WebSocket - $e');
       _errorMessage = "Lỗi kết nối chat: ${e.toString()}";
       notifyListeners();
    }
  }
  
  void _handleNewMessage(Message message) {
    bool messageExists = _messages.any((m) => m.id == message.id && m.id != null);
    
    if (!messageExists) {
      print("User MessageProvider: Nhận tin nhắn mới với ID: ${message.id}");
      _messages.insert(0, message);
      notifyListeners();
    } else {
      print("User MessageProvider: Message ${message.id} already exists. Skipping.");
    }
  }
  
  void _handleMessageRead(String messageId) {
    bool changed = false;
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].id == messageId && !_messages[i].isRead) {
        _messages[i] = _messages[i].copyWith(isRead: true);
        changed = true;
        break;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }
  
  void _handleMessageDeleted(String messageId) {
    final initialLength = _messages.length;
    _messages.removeWhere((message) => message.id == messageId);
    if (_messages.length < initialLength) {
      notifyListeners();
    }
  }
  
  Future<void> _sendMessageInternal(String userId, String content, List<ImageData>? imageDataListForWeb, List<File>? imagesForMobile) async {
    if (userId.isEmpty) {
      _errorMessage = "Không thể gửi tin nhắn: Thông tin người dùng không hợp lệ.";
      notifyListeners();
      return;
    }
    _errorMessage = null;

    try {
      if (kIsWeb) {
        if (imagesForMobile != null && imagesForMobile.isNotEmpty) {
           throw Exception("Sử dụng imageDataListForWeb cho web, không phải imagesForMobile");
        }
        await _repository.sendMessageWithBytes(userId, content, imageDataListForWeb);
      } else {
        if (imageDataListForWeb != null && imageDataListForWeb.isNotEmpty) {
           throw Exception("Sử dụng imagesForMobile cho mobile, không phải imageDataListForWeb");
        }
        await _repository.sendMessage(userId, content, imagesForMobile);
      }
    } catch (e) {
      _errorMessage = 'Không thể gửi tin nhắn: ${e.toString()}';
      print("User MessageProvider: Error sending message - $e");
      notifyListeners();
    }
  }

  Future<void> sendMessage(String userId, String content, List<File>? images) async {
    await _sendMessageInternal(userId, content, null, images);
  }
  
  Future<void> sendWebMessage(String userId, String content, List<XFile>? images) async {
    List<ImageData>? imageDataList;
    if (images != null && images.isNotEmpty) {
      imageDataList = [];
      for (var imageFile in images) {
        final bytes = await imageFile.readAsBytes();
        imageDataList.add(ImageData(
          bytes: bytes, 
          filename: imageFile.name,
          mimeType: imageFile.mimeType ?? 'image/jpeg'
        ));
      }
    }
    await _sendMessageInternal(userId, content, imageDataList, null);
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
  
  @override
  void dispose() {
    authProvider.removeListener(_updateUserIdFromAuthProvider);
    if (_currentUserId != null && _adminId != null) {
      _webSocketService.unsubscribeFromUserMessages(_currentUserId!, _adminId!);
      _webSocketService.unsubscribeFromMessageRead(_currentUserId!, _adminId!);
      _webSocketService.unsubscribeFromMessageDeleted(_currentUserId!, _adminId!);
    }
    super.dispose();
  }
} 