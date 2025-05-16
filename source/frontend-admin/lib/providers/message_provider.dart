import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../repository/message_repository.dart';
import '../core/services/websocket_service.dart';
import './auth_provider.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _repository = MessageRepository();
  final WebSocketService _webSocketService = WebSocketService();
  final AuthProvider authProvider;
  
  List<Message> _messages = [];
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  int _unreadCount = 0;
  String? _currentAdminId;
  
  List<Message> get messages => _messages;
  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  
  MessageProvider(this.authProvider) {
    _currentAdminId = authProvider.userId;
    authProvider.addListener(_updateAdminIdFromAuthProvider);
  }
  
  void _updateAdminIdFromAuthProvider() {
    if (_currentAdminId != authProvider.userId) {
      _currentAdminId = authProvider.userId;
      print("MessageProvider: Admin ID updated from AuthProvider: $_currentAdminId");
    }
  }
  
  void setSelectedUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }
  
  Future<void> loadUsers(String adminId) async {
    final effectiveAdminId = adminId.isNotEmpty ? adminId : _currentAdminId;

    if (effectiveAdminId == null || effectiveAdminId.isEmpty) {
      print('Lỗi: ID của admin trống và không có trong AuthProvider!');
      throw Exception('Admin ID is empty');
    }
    
    print('Đang tải danh sách người dùng với adminId: $effectiveAdminId');
    _isLoading = true;
    notifyListeners();
    
    try {
      _users = await _repository.getUsersWithMessages(effectiveAdminId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải danh sách người dùng: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> loadConversation(String userId, String adminId) async {
    final effectiveAdminId = adminId.isNotEmpty ? adminId : _currentAdminId;

    if (userId.isEmpty || effectiveAdminId == null || effectiveAdminId.isEmpty) {
      print('Lỗi: ID của user hoặc admin trống!');
      print('userId: $userId, adminId: $effectiveAdminId');
      throw Exception('User ID or Admin ID is empty');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('Đang tải cuộc hội thoại giữa userId: $userId và adminId: $effectiveAdminId');
      _messages = await _repository.getConversation(userId, effectiveAdminId);
      print('Đã tải ${_messages.length} tin nhắn');
      
      await _repository.markMessagesAsRead(userId, effectiveAdminId);
      await loadUnreadCount();
      _isLoading = false;
      
      _connectWebSocket(effectiveAdminId, userId);
      
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải cuộc hội thoại: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  void _connectWebSocket(String adminId, String userId) {
    final String? token = authProvider.token;

    if (token == null || token.isEmpty) {
      print('Lỗi: Không có token xác thực. Không thể kết nối WebSocket.');
      return;
    }

    try {
      print('Attempting to connect WebSocket for admin $adminId and user $userId with token.');
      _webSocketService.connect(token: token);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_webSocketService.isConnected) {
          print('WebSocket connected successfully. Subscribing to topics.');
          _webSocketService.subscribeToAdminMessages(adminId, userId, _handleNewMessage);
          _webSocketService.subscribeToMessageRead(adminId, userId, _handleMessageRead);
          _webSocketService.subscribeToMessageDeleted(adminId, userId, _handleMessageDeleted);
          print('WebSocket subscriptions completed for admin $adminId and user $userId.');
        } else {
          print('WebSocket failed to connect after attempt. Subscriptions skipped.');
        }
      });

    } catch (e) {
      print('Error connecting WebSocket: $e');
    }
  }
  
  void _handleNewMessage(Message message) {
    bool messageExists = _messages.any((m) => m.id == message.id && m.id != null);
    
    if (!messageExists) {
      print("Admin MessageProvider: Nhận tin nhắn mới với ID: ${message.id}");
      _messages.insert(0, message); 
      
      if (message.isFromUser && !message.isRead && _selectedUser?.id == message.userId) {
        _repository.markMessagesAsRead(message.userId, message.adminId).then((_) {
          loadUnreadCount();
        }).catchError((e) {
          print("Error marking message as read immediately: $e");
        });
      } else if (message.isFromUser && !message.isRead) {
        _unreadCount++;
      }
      
      notifyListeners();
    } else {
      print("Message ${message.id} already exists. Skipping.");
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
  
  Future<void> sendMessage(String adminId, String userId, String content, List<File>? images) async {
    final effectiveAdminId = adminId.isNotEmpty ? adminId : _currentAdminId;
     if (effectiveAdminId == null || effectiveAdminId.isEmpty) {
      print('Lỗi gửi tin nhắn: ID admin không hợp lệ.');
      throw Exception('Invalid Admin ID for sending message');
    }

    try {
      await _repository.sendMessage(effectiveAdminId, userId, content, images);

    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }
  
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _repository.countUnreadMessages();
      notifyListeners();
    } catch (e) {
      print("Error loading unread count: $e");
    }
  }
  
  Future<void> deleteMessage(String messageId) async {
    try {
      final success = await _repository.deleteMessage(messageId);
      if (success) {
        _messages.removeWhere((message) => message.id == messageId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  void dispose() {
    authProvider.removeListener(_updateAdminIdFromAuthProvider);
    if (_currentAdminId != null && _selectedUser != null) {
      _webSocketService.unsubscribeFromAdminMessages(_currentAdminId!, _selectedUser!.id);
      _webSocketService.unsubscribeFromMessageRead(_currentAdminId!, _selectedUser!.id);
      _webSocketService.unsubscribeFromMessageDeleted(_currentAdminId!, _selectedUser!.id);
    }
    super.dispose();
  }
} 