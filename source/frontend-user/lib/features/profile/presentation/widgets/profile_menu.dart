import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../screens/setting_screen.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Tài khoản của tôi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.shopping_bag,
            title: 'Đơn hàng của tôi',
            subtitle: 'Xem lịch sử đơn hàng và trạng thái',
            onTap: () {
              if (authProvider.isAuthenticated) {
                final userId = authProvider.userId;
                if (userId != null) {
                  NavigationHelper.navigateToOrderHistory(context, userId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Không thể xác định người dùng. Vui lòng đăng nhập lại.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Vui lòng đăng nhập để xem đơn hàng')),
                );
              }
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            context,
            icon: Icons.location_on,
            title: 'Địa chỉ của tôi',
            subtitle: 'Quản lý địa chỉ giao hàng',
            onTap: () {
              if (authProvider.isAuthenticated) {
                NavigationHelper.navigateToAddressManagement(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Vui lòng đăng nhập để quản lý địa chỉ')),
                );
              }
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Cài đặt tài khoản',
            subtitle: 'Bảo mật và thông tin cá nhân',
            onTap: () {
              if (authProvider.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Vui lòng đăng nhập để truy cập cài đặt')),
                );
              }
            },
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 24),
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
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
