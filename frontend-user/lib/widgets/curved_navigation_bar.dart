import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:frontend_user/screens/home_page.dart';
import '../screens/screen_controller.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final Function(Widget) onPageChange;
  
  const MyBottomNavigationBar({
    super.key,
    required this.onPageChange,
  });

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        ScreenController.setPageBody('Xây dựng cấu hình');
        widget.onPageChange(ScreenController.getPage());
        break;
      case 1:
        ScreenController.setPageBody('Hỗ trợ');
        widget.onPageChange(ScreenController.getPage());
        break;
      case 2:
        ScreenController.setPageBody('Giỏ hàng');
        widget.onPageChange(ScreenController.getPage());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.white,
      color: Colors.blue,
      buttonBackgroundColor: Colors.blue,
      animationDuration: const Duration(milliseconds: 300),
      index: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        CurvedNavigationBarItem(
          child: FaIcon(FontAwesomeIcons.screwdriverWrench, color: Colors.white),
          label: 'Xây dựng cấu hình',
          labelStyle: TextStyle(color: Colors.white)
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.phone, color: Colors.white),
          label: 'Hỗ trợ',
          labelStyle: TextStyle(color: Colors.white)
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.shopping_cart, color: Colors.white),
          label: 'Giỏ hàng',
          labelStyle: TextStyle(color: Colors.white)
        ),
      ],
    );
  }
}
