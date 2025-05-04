import 'package:flutter/material.dart';
import 'package:admin_interface/proxy/screen_access_interface.dart';
import 'package:admin_interface/features/coupons_management/screens/coupons_management_screen.dart';
import 'package:admin_interface/features/customers_support/screens/customers_support_screen.dart';
import 'package:admin_interface/features/home/screens/home_screen.dart';
import 'package:admin_interface/features/login/screens/login_screen.dart';
import 'package:admin_interface/features/orders_management/screens/orders_management_screen.dart';
import 'package:admin_interface/features/products_management/screens/products_management_screen.dart';
import 'package:admin_interface/features/products_promotion/screens/products_promotion_screen.dart';
import 'package:admin_interface/features/statistics/screens/statistics_screen.dart';
import 'package:admin_interface/features/users_management/screens/user_management_screen.dart';

// The RealScreenAccess provides the actual implementation of accessing screens
class RealScreenAccess implements ScreenAccessInterface {
  @override
  Widget getScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const ProductsManagementScreen();
      case 1:
        return const UsersManagementScreen();
      case 2:
        return const OrdersManagementScreen();
      default:
        return const ProductsManagementScreen();
    }
  }
}
