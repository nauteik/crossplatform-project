import 'package:flutter/material.dart';
import 'package:admin_interface/proxy/screen_access_interface.dart';
import 'package:admin_interface/features/coupons_management/screens/coupons_management_screen.dart';
import 'package:admin_interface/features/overview/screens/overview_screen.dart';
import 'package:admin_interface/features/orders_management/screens/orders_management_screen.dart';
import 'package:admin_interface/features/products_management/screens/products_management_screen.dart';
import 'package:admin_interface/features/statistics/screens/statistics_screen.dart';
import 'package:admin_interface/features/users_management/screens/user_management_screen.dart';

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
      default:
        return const OverviewScreen();
    }
  }
}
