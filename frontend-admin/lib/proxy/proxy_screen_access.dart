import 'package:flutter/material.dart';
import 'package:admin_interface/proxy/screen_access_interface.dart';
import 'package:admin_interface/proxy/real_screen_access.dart';
import 'package:admin_interface/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// The ProxyScreenAccess adds access control before allowing access to screens
class ProxyScreenAccess implements ScreenAccessInterface {
  final RealScreenAccess _realScreenAccess = RealScreenAccess();

  // List of screen indices that require admin permission
  final List<int> _adminOnlyScreens = [
    4
  ]; // UsersManagementScreen is at index 4

  @override
  Widget getScreen(int index, BuildContext context) {
    // Check if screen requires admin permission
    if (_adminOnlyScreens.contains(index)) {
      // Get auth provider to check role
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // If user is not admin, show access denied screen
      if (!authProvider.isAdmin()) {
        return _buildAccessDeniedScreen(context);
      }
    }

    // If permission check passes or screen doesn't require special permission,
    // delegate to real screen access
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
            const Icon(
              Icons.no_accounts,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quyền truy cập bị từ chối',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
