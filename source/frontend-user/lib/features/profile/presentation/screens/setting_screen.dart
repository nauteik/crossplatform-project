import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart'; // Thêm import này

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt tài khoản'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Thông tin cá nhân'),
          _buildSettingItem(
            context,
            icon: Icons.person,
            title: 'Thông tin tài khoản',
            subtitle: 'Xem và cập nhật thông tin cá nhân',
            onTap: () {
              // Điều hướng đến màn hình chỉnh sửa hồ sơ
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              ).then((value) {
                // Nếu có cập nhật profile, có thể làm mới màn hình Settings
                if (value == true) {
                  // Nếu muốn làm mới dữ liệu sau khi cập nhật profile
                  // Có thể thêm logic refresh ở đây
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thông tin cá nhân đã được cập nhật'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.lock,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          )   
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
