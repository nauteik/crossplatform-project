import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/cart_item_model.dart';
import '../../data/model/order_model.dart';
import '../../utils/route_transitions.dart';
import 'providers/payment_provider.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';

/// This class provides static methods to navigate to payment-related screens
/// and methods for integrating the payment feature into the application.
class PaymentFeature {
  /// Navigate to checkout screen
  /// 
  /// [context] BuildContext
  /// [userId] The user ID making the purchase, null for guest checkout
  /// [cartItems] List of items in the cart
  /// [totalAmount] Total amount to be paid
  static void navigateToCheckout({
    required BuildContext context,
    String? userId,
    required List<CartItemModel> cartItems,
    required double totalAmount,
  }) {
    // Reset payment provider state before navigating to checkout
    context.read<PaymentProvider>().reset();
    
    // Use slide transition for better user experience
    pushWithSlideTransition(
      context: context,
      page: CheckoutScreen(
        userId: userId,
        cartItems: cartItems,
        totalAmount: totalAmount,
      ),
    );
  }
  
  /// Navigate to order history screen
  ///
  /// [context] BuildContext
  /// [userId] The user ID whose orders to display
  static void navigateToOrderHistory({
    required BuildContext context,
    required String userId,
  }) {
    // Use slide transition for better user experience
    pushWithSlideTransition(
      context: context,
      page: OrderHistoryScreen(
        userId: userId,
      ),
    );
  }
  
  /// Get Provider for App setup
  ///
  /// Use this in your app's provider setup
  /// Example:
  /// ```dart
  /// MultiProvider(
  ///   providers: [
  ///     ...PaymentFeature.getProviders(),
  ///   ],
  ///   child: MyApp(),
  /// )
  /// ```
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<PaymentProvider>(
        create: (context) => PaymentProvider(),
      ),
    ];
  }
}