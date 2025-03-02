import 'package:flutter/material.dart';
import '../screens/screen_controller.dart';

class PopupMenuAccount extends StatefulWidget {
  final Function(Widget) onPageChange;
  
  const PopupMenuAccount({
    super.key,
    required this.onPageChange,
  });

  @override
  State<PopupMenuAccount> createState() => _PopupMenuAccountState();
}

class _PopupMenuAccountState extends State<PopupMenuAccount> {
  void _showPopupMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

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
            ScreenController.setPageBody('PROFILE');
            widget.onPageChange(ScreenController.getPage());
            break;
          case 'ORDERS':
            ScreenController.setPageBody('ORDERS');
            widget.onPageChange(ScreenController.getPage());
            break;
          case 'WISHLIST':
            ScreenController.setPageBody('WISHLIST');
            widget.onPageChange(ScreenController.getPage());
            break;
          case 'SETTINGS':
            ScreenController.setPageBody('SETTINGS');
            widget.onPageChange(ScreenController.getPage());
            break;
          case 'LOGOUT':
            // Handle logout
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
        children: [
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
