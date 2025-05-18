import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    // Không notify nếu đã đang loading
    if (!_isLoading) {
      _isLoading = true;
      // Tránh gọi notifyListeners() trong build bằng cách sử dụng Future.microtask
      Future.microtask(() => notifyListeners());
    }

    try {
      final response = await _repository.fetchUsers();

      if (response.isSuccess) {
        _users = response.data ?? [];
        _errorMessage = null;
      } else {
        _users = [];
        _errorMessage = response.message?.isNotEmpty == true
            ? response.message
            : 'Lỗi không xác định khi lấy dữ liệu người dùng.';
      }
    } catch (e) {
      _users = [];
      _errorMessage = 'Lỗi: $e';
    } finally {
      _isLoading = false;
      // Đảm bảo notifyListeners() không được gọi trong build
      if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
        notifyListeners();
      } else {
        Future.microtask(() => notifyListeners());
      }
    }
  }

  // Thêm người dùng mới
  Future<bool> addUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _repository.addUser(userData);

    if (response.isSuccess) {
      _setErrorMessage(null);
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchUsers();
      return true; 
    } else {
      _setErrorMessage(response.message.isNotEmpty ? response.message : 'Thêm người dùng thất bại.');
      _setLoading(false);
      return false;
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _repository.updateUser(userId, userData);

    if (response.isSuccess) {
      if (response.data != null) {
        int index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = response.data!;
           _setErrorMessage(null);
           _setLoading(false);
           return true;
        }
      }
       _setErrorMessage(null);
       _setLoading(false);
       await Future.delayed(const Duration(milliseconds: 500));
       await fetchUsers();
       return true;
    } else {
      _setErrorMessage(response.message.isNotEmpty ? response.message : 'Cập nhật người dùng thất bại.');
      _setLoading(false);
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
      // await Future.delayed(const Duration(milliseconds: 500));
      // await fetchUsers();
      return true;
    } else {
      _setErrorMessage(response.message.isNotEmpty ? response.message : 'Xóa người dùng thất bại.');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods 
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      // Đảm bảo notifyListeners() không được gọi trong build
      if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
        notifyListeners();
      } else {
        Future.microtask(() => notifyListeners());
      }
    }
  }

  void _setErrorMessage(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      // Đảm bảo notifyListeners() không được gọi trong build
      if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
        notifyListeners();
      } else {
        Future.microtask(() => notifyListeners());
      }
    }
  }
}