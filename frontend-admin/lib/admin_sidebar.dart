import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminSidebar extends StatelessWidget {
  final SidebarXController sidebarXController;

  const AdminSidebar({super.key, required this.sidebarXController});

  @override
  Widget build(BuildContext context) {
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
      items: const [
        SidebarXItem(icon: FontAwesomeIcons.house, label: 'Home'),
        SidebarXItem(icon: FontAwesomeIcons.chartSimple, label: 'Statistics'),
        SidebarXItem(icon: FontAwesomeIcons.circleInfo, label: 'Customers Support'),
        SidebarXItem(icon: FontAwesomeIcons.warehouse, label: 'Products Management'),
        SidebarXItem(icon: FontAwesomeIcons.users, label: 'Users Management'),
        SidebarXItem(icon: FontAwesomeIcons.ticketSimple, label: 'Coupons Management'),
        SidebarXItem(icon: FontAwesomeIcons.truckRampBox, label: 'Orders Management'),
        SidebarXItem(icon: FontAwesomeIcons.percent, label: 'Products Promotion'),
        SidebarXItem(icon: FontAwesomeIcons.rightToBracket, label: 'Login'),
        SidebarXItem(icon: FontAwesomeIcons.rightFromBracket, label: 'Logout'),
      ],
    );
  }
}