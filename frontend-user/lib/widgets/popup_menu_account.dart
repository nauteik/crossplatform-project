import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/navigation/providers/navigation_provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/order_screen.dart';
import '../features/profile/presentation/screens/wishlist_screen.dart';
import '../features/profile/presentation/screens/setting_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class PopupMenuAccount extends StatefulWidget {
  const PopupMenuAccount({
    super.key,
  });

  @override
  State<PopupMenuAccount> createState() => _PopupMenuAccountState();
}

class _PopupMenuAccountState extends State<PopupMenuAccount> {
  void _showPopupMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showMenu(
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        0,
        0,
      ),
      items: [
        _buildMenuItem(
          'PROFILE',
          'Thông tin cá nhân',
          Icons.person,
          Colors.blue,
        ),
        _buildMenuItem(
          'ORDERS',
          'Đơn hàng của tôi',
          Icons.shopping_bag,
          Colors.blue,
        ),
        _buildMenuItem(
          'WISHLIST',
          'Sản phẩm yêu thích',
          Icons.favorite,
          Colors.blue,
        ),
        _buildMenuItem(
          'SETTINGS',
          'Cài đặt tài khoản',
          Icons.settings,
          Colors.blue,
        ),
        _buildMenuItem(
          'LOGOUT',
          'Đăng xuất',
          Icons.logout,
          Colors.red,
          textColor: Colors.red,
        ),
      ],
    ).then((String? value) {
      if (value != null) {
        switch (value) {
          case 'PROFILE':
            navigationProvider.setCurrentScreen(const ProfileScreen());
            break;
          case 'ORDERS':
            navigationProvider.setCurrentScreen(const OrderScreen());
            break;
          case 'WISHLIST':
            navigationProvider.setCurrentScreen(const WishlistScreen());
            break;
          case 'SETTINGS':
            navigationProvider.setCurrentScreen(const SettingScreen());
            break;
          case 'LOGOUT':
            authProvider.logout();
            navigationProvider.setCurrentScreen(const HomeScreen());
            break;
        }
      }
    });
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    String text,
    IconData icon,
    Color iconColor, {
    Color textColor = Colors.black87,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showPopupMenu,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.account_circle, color: Colors.white),
          Text(
            'Tài khoản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
