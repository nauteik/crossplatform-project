import 'package:flutter/material.dart';
import 'package:admin_interface/proxy/screen_access_interface.dart';
import 'package:admin_interface/proxy/real_screen_access.dart';
import 'package:admin_interface/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProxyScreenAccess implements ScreenAccessInterface {
  final RealScreenAccess _realScreenAccess = RealScreenAccess();

  // Danh sách các màn hình yêu cầu quyền admin (role = 1)
  final List<int> _adminOnlyScreens = [
    4, // UsersManagementScreen
  ];

  @override
  Widget getScreen(int index, BuildContext context) {
    // Chỉ kiểm tra quyền nếu là màn hình dành riêng cho admin
    if (_adminOnlyScreens.contains(index)) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isLoggedIn) {
        // Chưa đăng nhập
        return _buildAccessDeniedScreen(
          context,
          'Bạn cần đăng nhập để truy cập trang này',
          needLogin: true,
        );
      } else if (!authProvider.isAdmin()) {
        // Đã đăng nhập nhưng không phải admin
        return _buildAccessDeniedScreen(
          context,
          'Bạn không có quyền truy cập vào trang này.'
        );
      }
    }

    // Trả về màn hình thực tế
    return _realScreenAccess.getScreen(index, context);
  }

  // Màn hình thông báo không có quyền truy cập
  Widget _buildAccessDeniedScreen(BuildContext context, String message,
      {bool needLogin = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quyền truy cập bị từ chối'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Quyền truy cập bị từ chối',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            if (authProvider.isLoggedIn)
              Text(
                'Quyền hiện tại: ${authProvider.isAdmin() ? "Admin" : "User thường"} (role=${authProvider.userRole})',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Quay lại màn hình dashboard
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: const Text('Quay lại Dashboard'),
                ),
                const SizedBox(width: 16),
                if (needLogin)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Đăng nhập'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      authProvider.logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Đăng xuất'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
