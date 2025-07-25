import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_admin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminSidebar extends StatelessWidget {
  final SidebarXController sidebarXController;

  const AdminSidebar({super.key, required this.sidebarXController});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (screenWidth < 900 && sidebarXController.extended) {
        sidebarXController.setExtended(false);
      } else if (screenWidth >= 900 && !sidebarXController.extended) {
        sidebarXController.setExtended(true);
      }
    });

    return SidebarX(
      controller: sidebarXController,
      theme: SidebarXTheme(
        decoration: BoxDecoration(
          color: const Color(0xFF17153B),
        ),
        textStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        selectedTextStyle: const TextStyle(color: Colors.white),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemDecoration: BoxDecoration(
          color: const Color(0xFF433D8B),
          borderRadius: BorderRadius.circular(5),
        ),
        itemTextPadding: const EdgeInsets.only(left: 20),
      ),
      extendedTheme: SidebarXTheme(
        width: 220,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF17153B),
          borderRadius: BorderRadius.circular(10),
        ),
        selectedItemTextPadding: const EdgeInsets.only(left: 20),
      ),
      footerBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF17153B),
          child: Column(
            children: [
              const Divider(color: Colors.white38),
              ListTile(
                leading: const Icon(FontAwesomeIcons.rightFromBracket,
                    color: Colors.white),
                title: extended 
                    ? const Text('Đăng xuất', style: TextStyle(color: Colors.white))
                    : null,
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        );
      },
      items: const [
        SidebarXItem(icon: FontAwesomeIcons.house, label: 'Tổng quan'),
        SidebarXItem(icon: FontAwesomeIcons.chartSimple, label: 'Thống kê'),
        SidebarXItem(icon: FontAwesomeIcons.warehouse, label: 'Quản lý sản phẩm'),
        SidebarXItem(icon: FontAwesomeIcons.users, label: 'Quản lý người dùng'),
        SidebarXItem(icon: FontAwesomeIcons.truckRampBox, label: 'Quản lý đơn hàng'),
        SidebarXItem(icon: FontAwesomeIcons.tag, label: 'Quản lý khuyến mãi'),
        SidebarXItem(icon: FontAwesomeIcons.headset, label: 'Hỗ trợ khách hàng'),
      ],
    );
  }
}
