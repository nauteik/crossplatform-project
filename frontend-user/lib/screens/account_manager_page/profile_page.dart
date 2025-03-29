import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

  // User data
  String _username = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _rank = '';

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

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
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');

      if (userData != null) {
        final data = jsonDecode(userData);
        setState(() {
          _username = data['username'] ?? 'User';
          _name = data['name'] ?? 'New User';
          _email = data['email'] ?? 'example@email.com';
          _phone = data['phone'] ?? '';
          _address = data['address'] ?? '';
          _rank = data['rank'] ?? 'Bronze';

          _nameController.text = _name;
          _emailController.text = _email;
          _phoneController.text = _phone;
          _addressController.text = _address;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = {
        'username': _username,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'rank': _rank
      };

      await prefs.setString('user_data', jsonEncode(userData));

      setState(() {
        _name = _nameController.text;
        _email = _emailController.text;
        _phone = _phoneController.text;
        _address = _addressController.text;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thông tin đã được cập nhật')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu thông tin: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
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
                style: TextStyle(fontSize: 48, color: Colors.blue.shade700),
              ),
            ),
            SizedBox(height: 16),

            // Username (not editable)
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Tên đăng nhập'),
                subtitle: Text(_username),
              ),
            ),

            // Rank Badge (not editable)
            Card(
              child: ListTile(
                leading: Icon(Icons.military_tech, color: Colors.amber),
                title: Text('Hạng thành viên'),
                subtitle: Text(_rank),
                trailing: _getRankIcon(),
              ),
            ),

            SizedBox(height: 24),
            Text('Thông tin cá nhân',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),

            // Name
            _buildTextField(
              controller: _nameController,
              label: 'Họ tên',
              icon: Icons.badge,
              enabled: _isEditing,
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),

            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              enabled: _isEditing,
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
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isEmpty) return null; // Phone is optional
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Số điện thoại phải có 10 chữ số';
                }
                return null;
              },
            ),

            // Address
            _buildTextField(
              controller: _addressController,
              label: 'Địa chỉ',
              icon: Icons.home,
              enabled: _isEditing,
              maxLines: 2,
            ),

            SizedBox(height: 24),

            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Hủy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = _name;
                        _emailController.text = _email;
                        _phoneController.text = _phone;
                        _addressController.text = _address;
                      });
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Lưu thay đổi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveUserData,
                  ),
                ],
              ),
          ],
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
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
        return Icon(Icons.workspace_premium, color: Colors.brown);
      case 'silver':
        return Icon(Icons.workspace_premium, color: Colors.grey);
      case 'gold':
        return Icon(Icons.workspace_premium, color: Colors.amber);
      case 'platinum':
        return Icon(Icons.diamond, color: Colors.lightBlueAccent);
      default:
        return Icon(Icons.workspace_premium, color: Colors.brown);
    }
  }
}
