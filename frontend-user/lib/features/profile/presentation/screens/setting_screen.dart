import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt tài khoản', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
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
              // TODO: Điều hướng đến màn hình thông tin tài khoản
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.lock,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn',
            onTap: () {
              // TODO: Điều hướng đến màn hình đổi mật khẩu
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.location_on,
            title: 'Địa chỉ giao hàng',
            subtitle: 'Quản lý địa chỉ giao hàng của bạn',
            onTap: () {
              // TODO: Điều hướng đến màn hình quản lý địa chỉ
            },
          ),
          
          _buildSectionHeader('Bảo mật'),
          _buildSettingItem(
            context,
            icon: Icons.security,
            title: 'Xác thực hai yếu tố',
            subtitle: 'Bảo vệ tài khoản của bạn với xác thực hai yếu tố',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Xử lý bật/tắt xác thực hai yếu tố
              },
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Quyền riêng tư',
            subtitle: 'Quản lý cài đặt quyền riêng tư của bạn',
            onTap: () {
              // TODO: Điều hướng đến màn hình quyền riêng tư
            },
          ),
          
          _buildSectionHeader('Thông báo'),
          _buildSettingItem(
            context,
            icon: Icons.notifications,
            title: 'Thông báo đẩy',
            subtitle: 'Nhận thông báo về đơn hàng, khuyến mãi, tin tức',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Xử lý bật/tắt thông báo đẩy
              },
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.email,
            title: 'Thông báo qua email',
            subtitle: 'Nhận thông báo qua email',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Xử lý bật/tắt thông báo qua email
              },
            ),
          ),
          
          _buildSectionHeader('Khác'),
          _buildSettingItem(
            context,
            icon: Icons.help,
            title: 'Trung tâm trợ giúp',
            subtitle: 'Câu hỏi thường gặp và hỗ trợ',
            onTap: () {
              // TODO: Điều hướng đến màn hình trợ giúp
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.info,
            title: 'Về ứng dụng',
            subtitle: 'Phiên bản 1.0.0',
            onTap: () {
              // TODO: Hiển thị thông tin về ứng dụng
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: 'Đăng xuất',
            titleColor: Colors.red,
            onTap: () {
              // TODO: Xử lý đăng xuất
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Xử lý đăng xuất
                        Navigator.pop(context);
                      },
                      child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
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