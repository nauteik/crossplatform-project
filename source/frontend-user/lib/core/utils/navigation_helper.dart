import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/product_review_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/payment/screens/order_history_screen.dart';
import '../../features/profile/presentation/screens/address_screen.dart';
import '../../utils/route_transitions.dart';
import '../../core/models/address_model.dart';

class NavigationHelper {
  static Future<T?> navigateToLogin<T>(BuildContext context) {
    return pushWithSlideTransition(
      context: context,
      page: const LoginScreen(),
    );
  }

  static Future<T?> navigateToRegister<T>(BuildContext context) {
    return pushWithSlideTransition(
      context: context,
      page: const RegisterScreen(),
    );
  }

  static Future<T?> navigateToProductDetail<T>(
      BuildContext context, String productId) {
    return pushWithSlideTransition(
      context: context,
      page: ProductDetailScreen(productId: productId),
    );
  }

  static Future<T?> navigateToProductReview<T>(
      BuildContext context, String productId) {
    return pushWithSlideTransition(
      context: context,
      page: ProductReviewScreen(productId: productId),
    );
  }

  static Future<T?> navigateToCart<T>(BuildContext context) {
    return pushWithSlideTransition(
      context: context,
      page: const CartScreen(),
    );
  }

  static Future<T?> navigateToOrderHistory<T>(
      BuildContext context, String userId) {
    return pushWithSlideTransition(
      context: context,
      page: OrderHistoryScreen(userId: userId),
    );
  }

  static Future<T?> navigateToAddressManagement<T>(BuildContext context) {
    return pushWithSlideTransition(
      context: context,
      page: const AddressScreen(),
    );
  }

  static Future<AddressModel?> navigateToAddressSelection<T>(
      BuildContext context) {
    return Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (context) => AddressScreen(
          isSelecting: true,
          onAddressSelected: (address) {
            Navigator.of(context).pop(address);
          },
        ),
      ),
    );
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }
}
