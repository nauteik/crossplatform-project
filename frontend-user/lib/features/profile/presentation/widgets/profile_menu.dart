import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../screens/setting_screen.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.shopping_bag,
            title: 'Đơn hàng của tôi',
            subtitle: 'Xem lịch sử đơn hàng và trạng thái',
            onTap: () {
              // TODO: Điều hướng đến màn hình đơn hàng khi được tạo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển!')),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.favorite,
            title: 'Sản phẩm yêu thích',
            subtitle: 'Xem danh sách sản phẩm đã lưu',
            onTap: () {
              // TODO: Điều hướng đến màn hình yêu thích khi được tạo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển!')),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.location_on,
            title: 'Địa chỉ của tôi',
            subtitle: 'Quản lý địa chỉ giao hàng',
            onTap: () {
              // TODO: Điều hướng đến màn hình địa chỉ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển!')),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.support_agent,
            title: 'Hỗ trợ khách hàng',
            subtitle: 'Liên hệ với chúng tôi khi bạn cần giúp đỡ',
            onTap: () {
              // TODO: Điều hướng đến màn hình hỗ trợ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển!')),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Cài đặt tài khoản',
            subtitle: 'Thay đổi mật khẩu, thông tin cá nhân',
            onTap: () => _navigateTo(context, const SettingScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setCurrentScreen(screen);
  }
} 