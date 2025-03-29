// widgets/navigation/main_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/navigation/providers/navigation_provider.dart';
import '../../features/home/presentation/screens/landing_screen.dart';
import '../appbar.dart';
import 'bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Đặt màn hình mặc định khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
      navigationProvider.setCurrentScreen(const LandingScreen());
      print("MainLayout initState - Màn hình mặc định đã được thiết lập: LandingScreen");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        print("MainLayout build - Màn hình hiện tại: ${navigationProvider.currentScreen.runtimeType}");
        return Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: NavBar(),
          ),
          body: SingleChildScrollView(
            child: navigationProvider.currentScreen,
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: _currentIndex,
            onIndexChanged: _updateIndex,
          ),
        );
      },
    );
  }
}