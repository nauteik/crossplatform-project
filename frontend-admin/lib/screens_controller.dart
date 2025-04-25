import 'package:admin_interface/features/coupons_management/screens/coupons_management_screen.dart';
import 'package:admin_interface/features/customers_support/screens/customers_support_screen.dart';
import 'package:admin_interface/features/home/screens/home_screen.dart';
import 'package:admin_interface/features/login/screens/login_screen.dart';
import 'package:admin_interface/features/orders_management/screens/orders_management_screen.dart';
import 'package:admin_interface/features/products_management/screens/products_management_screen.dart';
import 'package:admin_interface/features/products_promotion/screens/products_promotion_screen.dart';
import 'package:admin_interface/features/statistics/screens/statistics_screen.dart';
import 'package:admin_interface/features/users_management/screens/user_management_screen.dart';
import 'package:flutter/material.dart';

Widget navigateToScreen(int index) {
  switch(index) {
    case 0:
      return HomeScreen();
    case 1:
      return StatisticsScreen();
    case 2:
      return CustomersSupportScreen();
    case 3:
      return ProductsManagementScreen();
    case 4:
      return UsersManagementScreen();
    case 5:
      return CouponsManagementScreen();
    case 6:
      return OrdersManagementScreen();
    case 7:
      return ProductsPromotionScreen();
    case 8:
      return LoginScreen();
    default:
      return HomeScreen();
  }
}