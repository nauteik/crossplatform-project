import 'package:admin_interface/screens/coupons_management.dart';
import 'package:admin_interface/screens/orders_management.dart';
import 'package:admin_interface/screens/products_management.dart';
import 'package:admin_interface/screens/products_promotion.dart';
import 'package:admin_interface/screens/users_management.dart';
import 'home.dart';
import 'package:flutter/material.dart';
import 'view_statistics.dart';
import 'customer_support.dart';

Widget getScreen(int index) {
  switch(index) {
    case 0:
      return const HomeScreen();
    case 1:
      return const ViewStatistics();
    case 2:
      return const CustomerSupport();
    case 3:
      return const ProductsManagement();
    case 4:
      return const UsersManagement();
    case 5:
      return const CouponsManagement();
    case 6:
      return const OrdersManagement();
    case 7:
      return const ProductsPromotion();
    default:
      return const HomeScreen();
  }
}