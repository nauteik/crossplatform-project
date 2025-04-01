import 'package:flutter/material.dart';

class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class SlideLeftRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlideLeftRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

// Helper function để push route với animation (slide từ phải sang trái)
Future<T?> pushWithSlideTransition<T>({
  required BuildContext context,
  required Widget page,
}) {
  return Navigator.of(context).push(SlideRightRoute<T>(page: page));
}

// Helper function để pop và push route mới với animation (slide từ trái sang phải)
Future<T?> popAndPushWithSlideTransition<T>({
  required BuildContext context,
  required Widget page,
}) {
  Navigator.of(context).pop();
  return Navigator.of(context).push(SlideLeftRoute<T>(page: page));
}
