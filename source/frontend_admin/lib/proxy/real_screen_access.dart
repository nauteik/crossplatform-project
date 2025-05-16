import 'package:flutter/material.dart';
import 'package:frontend_admin/features/coupons_management/screens/coupons_management_screen.dart';
import 'package:frontend_admin/features/customers_support/screens/chat_support_screen.dart';
import 'package:frontend_admin/features/orders_management/screens/orders_management_screen.dart';
import 'package:frontend_admin/features/overview/screens/overview_screen.dart';
import 'package:frontend_admin/features/products_management/screens/products_management_screen.dart';
import 'package:frontend_admin/features/statistics/screens/statistics_screen.dart';
import 'package:frontend_admin/features/users_management/screens/user_management_screen.dart';
import 'package:frontend_admin/proxy/screen_access_interface.dart';

// The RealScreenAccess provides the actual implementation of accessing screens
class RealScreenAccess implements ScreenAccessInterface {
  @override
  Widget getScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const OverviewScreen();
      case 1:
        return const StatisticsScreen();
      case 2:
        return const ProductsManagementScreen();
      case 3:
        return const UsersManagementScreen();
      case 4:
        return const OrdersManagementScreen();
      case 5:
        return const CouponsManagementScreen();
      case 6:
        return const ChatSupportScreen();
      default:
        return const OverviewScreen();
    }
  }
}
