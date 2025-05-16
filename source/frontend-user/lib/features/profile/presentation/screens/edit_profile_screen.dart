import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json, jsonDecode, jsonEncode, utf8;
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../data/repositories/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // User data
  String _id = '';
  String _username = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _rank = '';

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Thêm repository vào class
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Tải dữ liệu cơ bản từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');

      if (userData != null) {
        // Decode chuỗi JSON với UTF-8 rõ ràng
        final data = json.decode(userData);
        setState(() {
          _id = data['id'] ?? '';
          _username = data['username'] ?? 'Người dùng';
          _name = data['name'] ?? 'Chưa cập nhật';
          _email = data['email'] ?? 'Chưa cập nhật';
          _phone = data['phone'] ?? 'Chưa cập nhật';
          _rank = data['rank'] ?? 'Bronze';

          _nameController.text = _name != 'Chưa cập nhật' ? _name : '';
          _emailController.text = _email != 'example@email.com' ? _email : '';
          _phoneController.text = _phone != 'Chưa cập nhật' ? _phone : '';
        });
      }

      // 2. Nếu có ID người dùng, gọi API để lấy thông tin mới nhất
      if (_id.isNotEmpty) {
        await _fetchUserDetails();
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin người dùng: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Thêm phương thức _fetchUserDetails
  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await _userRepository.getCurrentUserDetails();

      if (userDetails != null) {
        setState(() {
          // Sử dụng giá trị mặc định tiếng Việt đúng encoding
          _name = userDetails['name'] ?? 'Chưa cập nhật';
          _email = userDetails['email'] ?? 'Chưa cập nhật';
          _phone = userDetails['phone'] ?? 'Chưa cập nhật';
          _rank = userDetails['rank'] ?? 'Bronze';

          // Chỉ cập nhật controllers khi có giá trị thực sự
          if (_name != 'Chưa cập nhật') _nameController.text = _name;
          if (_email != 'Chưa cập nhật') _emailController.text = _email;
          if (_phone != 'Chưa cập nhật') _phoneController.text = _phone;
        });

        // Cập nhật SharedPreferences với xử lý UTF-8 đúng cách
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDataStr = prefs.getString('user_data');

        if (userDataStr != null) {
          final data = jsonDecode(userDataStr);
          data['name'] = _name;
          data['email'] = _email;
          data['phone'] = _phone;
          data['rank'] = _rank;

          // Encode với UTF-8
          final encodedJson = jsonEncode(data);
          await prefs.setString('user_data', encodedJson);
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Chuẩn bị dữ liệu để gửi lên server
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      // Gọi API để cập nhật thông qua repository
      final success = await _userRepository.updateUserProfile(_id, updatedData);

      if (success) {
        // Cập nhật dữ liệu local với xử lý UTF-8 đúng cách
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDataStr = prefs.getString('user_data');

        if (userDataStr != null) {
          final data = jsonDecode(userDataStr);
          data['name'] = _nameController.text;
          data['email'] = _emailController.text;
          data['phone'] = _phoneController.text;

          // Encode với UTF-8
          final encodedJson = jsonEncode(data);
          await prefs.setString('user_data', encodedJson);
        }

        setState(() {
          _name = _nameController.text;
          _email = _emailController.text;
          _phone = _phoneController.text;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông tin đã được cập nhật')),
        );
        Navigator.pop(context, true); // Quay lại với kết quả thành công
      } else {
        throw Exception('Cập nhật thông tin thất bại');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu thông tin: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Thêm một nút debug để kiểm tra thông tin người dùng
  void _debugUserData() async {
    try {
      final details = await _userRepository.getCurrentUserDetails();
      print('User details from API: $details');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      print('User data from SharedPreferences: $userData');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã in thông tin debug vào console')),
      );
    } catch (e) {
      print('Debug error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thêm nút debug vào AppBar
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserData,
            tooltip: 'Lưu thay đổi',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugUserData,
            tooltip: 'Debug',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                        style: TextStyle(
                            fontSize: 48, color: Colors.blue.shade700),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Username (not editable)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Tên đăng nhập'),
                        subtitle: Text(_username),
                      ),
                    ),

                    // Rank Badge (not editable)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.military_tech,
                            color: Colors.amber),
                        title: const Text('Hạng thành viên'),
                        subtitle: Text(_rank),
                        trailing: _getRankIcon(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Thông tin cá nhân',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),

                    // Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Họ tên',
                      icon: Icons.badge,
                      validator: (value) =>
                          value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Vui lòng nhập email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) return null; // Phone is optional
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Số điện thoại phải có 10 chữ số';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu thay đổi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saveUserData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
        ),
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _getRankIcon() {
    switch (_rank.toLowerCase()) {
      case 'bronze':
        return const Icon(Icons.workspace_premium, color: Colors.brown);
      case 'silver':
        return const Icon(Icons.workspace_premium, color: Colors.grey);
      case 'gold':
        return const Icon(Icons.workspace_premium, color: Colors.amber);
      case 'platinum':
        return const Icon(Icons.diamond, color: Colors.lightBlueAccent);
      default:
        return const Icon(Icons.workspace_premium, color: Colors.brown);
    }
  }
}
