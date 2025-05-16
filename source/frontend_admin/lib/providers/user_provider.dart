import 'package:flutter/material.dart';
import 'package:frontend_admin/models/user_model.dart';
import 'package:frontend_admin/repository/user_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementRepository _repository;

  UserManagementProvider(this._repository);

  // State
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _repository.fetchUsers();

    if (response.isSuccess) {
      _users = response.data ?? [];
      _setErrorMessage(null);
    } else {
      _users = [];
      _setErrorMessage(response.message);
    }

    _setLoading(false);
  }

  // Thêm người dùng mới
  Future<bool> addUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _repository.addUser(userData);

    if (response.isSuccess && response.data != null) {
      _setErrorMessage(null);
      _setLoading(false);
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchUsers();
      return true;
    } else {
      _setErrorMessage(response.message.isNotEmpty ? response.message : 'Thêm người dùng thất bại.');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _repository.updateUser(userId, userData);

    if (response.isSuccess && response.data != null) {
      int index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = response.data!;
      }
      _setErrorMessage(null);
      _setLoading(false);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchUsers();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  // Xóa người dùng
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _repository.deleteUser(userId);

    if (response.isSuccess) {
      _users.removeWhere((user) => user.id == userId);
      _setErrorMessage(null);
      _setLoading(false);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchUsers();
      return true;
    } else {
      _setErrorMessage(response.message.isNotEmpty ? response.message : 'Xóa người dùng thất bại.');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    if (_isLoading != value) {
       _isLoading = value;
       notifyListeners();
    }
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
     if (_errorMessage != message) {
        _errorMessage = message;
        notifyListeners();
     }
  }
}