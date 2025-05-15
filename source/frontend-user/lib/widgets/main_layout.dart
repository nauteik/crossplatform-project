// widgets/navigation/main_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/navigation/providers/navigation_provider.dart';
import 'bottom_navigation.dart';
import 'navigation_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final currentScreen = navigationProvider.currentScreen;
        
        // Kiểm tra nếu là web và dùng responsive layout
        if (kIsWeb) {
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: NavigationHandler(
                  child: Scaffold(
                    body: currentScreen,
                    bottomNavigationBar: const BottomNavigation(),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Mobile layout như cũ
          return NavigationHandler(
            child: Scaffold(
              body: currentScreen,
              bottomNavigationBar: const BottomNavigation(),
            ),
          );
        }
      },
    );
  }
}