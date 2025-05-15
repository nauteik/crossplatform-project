import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../repository/message_repository.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _repository = MessageRepository();
  
  List<Message> _messages = [];
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  int _unreadCount = 0;
  
  List<Message> get messages => _messages;
  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  
  void setSelectedUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }
  
  Future<void> loadUsers(String adminId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _users = await _repository.getUsersWithMessages(adminId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> loadConversation(String userId, String adminId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _messages = await _repository.getConversation(userId, adminId);
      await _repository.markMessagesAsRead(userId, adminId);
      await loadUnreadCount();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> sendMessage(String adminId, String userId, String content, List<File>? images) async {
    try {
      final message = await _repository.sendMessage(adminId, userId, content, images);
      _messages.insert(0, message); // Thêm tin nhắn mới vào đầu danh sách
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _repository.countUnreadMessages();
      notifyListeners();
    } catch (e) {
      rethrow;
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
} 