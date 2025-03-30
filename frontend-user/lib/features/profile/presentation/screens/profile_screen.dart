import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/profile_menu.dart';
import '../widgets/profile_header.dart';
import '../widgets/login_button.dart';
import '../widgets/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (isAuthenticated) ...[ // Đã đăng nhập -> Hiện ProfileHeader
                ProfileHeader(authProvider: authProvider),
                const SizedBox(height: 16),
              ] else ...[               // Không đăng nhập -> Hiện nút Login
                const LoginButton(),
                const SizedBox(height: 16),
              ],
              const ProfileMenu(),    // Luôn hiện dù đăng nhập hay không
              const SizedBox(height: 16),
              if (isAuthenticated)    // Đã đăng nhập -> Hiện nút Logout
                const LogoutButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 