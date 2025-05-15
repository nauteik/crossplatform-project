import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
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
                    // Xử lý đăng xuất
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
                    
                    // Đóng hộp thoại xác nhận
                    Navigator.pop(context);
                    
                    // Thực hiện đăng xuất
                    authProvider.logout(context);
                    
                    // Sử dụng phương thức resetToHome để quay về trang chủ
                    navigationProvider.resetToHome();
                  },
                  child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Đăng xuất'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
} 