import 'package:flutter/material.dart';
import 'package:frontend_admin/providers/auth_provider.dart';
import 'package:frontend_admin/proxy/real_screen_access.dart';
import 'package:frontend_admin/proxy/screen_access_interface.dart';
import 'package:provider/provider.dart';

// The ProxyScreenAccess adds access control before allowing access to screens
class ProxyScreenAccess implements ScreenAccessInterface {
  final RealScreenAccess _realScreenAccess = RealScreenAccess();

  // List of screen indices that require admin permission - now empty
  final List<int> _adminOnlyScreens = [

    // 4 - removing restriction for UsersManagementScreen
  ];


  @override
  Widget getScreen(int index, BuildContext context) {
    // Kiểm tra không còn cần thiết nhưng giữ lại cấu trúc code để dễ thêm lại sau này nếu cần
    if (_adminOnlyScreens.contains(index)) {
      // Get auth provider to check role
      final authProvider = Provider.of<AuthProvider>(context);
      print('Current user role: ${authProvider.currentUser?.role}');
      if (!authProvider.isAdmin()) {
        return _buildAccessDeniedScreen(context);
      }
    }
    return _realScreenAccess.getScreen(index, context);
  }

  // Build an access denied screen
  Widget _buildAccessDeniedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quyền truy cập bị từ chối'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_accounts, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Quyền truy cập bị từ chối',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn không có quyền truy cập vào trang này.\nVui lòng liên hệ quản trị viên nếu bạn cần truy cập.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Đăng nhập lại'),
            ),
          ],
        ),
      ),
    );
  }
}
