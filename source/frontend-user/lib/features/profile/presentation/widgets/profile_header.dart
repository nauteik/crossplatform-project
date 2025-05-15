import 'package:flutter/material.dart';
import '../../../auth/providers/auth_provider.dart';
import '../screens/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final AuthProvider authProvider;

  const ProfileHeader({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final userData = authProvider.userData;
    final username = userData?['username'] ?? 'Người dùng';
    final email = userData?['email'] ?? 'Chưa có email';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 70,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              // Điều hướng đến màn hình chỉnh sửa hồ sơ
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );

              // Nếu có sự thay đổi (result == true), có thể refresh lại thông tin
              if (result == true) {
                // Refresh thông tin người dùng
                authProvider.refreshUserData(context);
              }
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
