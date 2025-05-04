// widgets/navigation/main_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/navigation/providers/navigation_provider.dart';
import 'bottom_navigation.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        print("MainLayout build - Màn hình hiện tại: ${navigationProvider.currentScreen.runtimeType}");
        return Scaffold(
          body: navigationProvider.currentScreen,
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }
}