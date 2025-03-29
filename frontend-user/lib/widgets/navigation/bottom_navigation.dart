import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/navigation/providers/navigation_provider.dart';
import '../../features/build_pc/presentation/screens/build_configuration_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  void _onItemTapped(int index) {
    widget.onIndexChanged(index);
    
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
    switch (index) {
      case 0:
        print("BottomNavigation - Chuyển đến BuildConfigurationScreen");
        navigationProvider.setCurrentScreen(const BuildConfigurationScreen());
        break;
      case 1:
        print("BottomNavigation - Chuyển đến SupportScreen");
        navigationProvider.setCurrentScreen(const SupportScreen());
        break;
      case 2:
        print("BottomNavigation - Chuyển đến CartScreen");
        navigationProvider.setCurrentScreen(const CartScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: 'Xây dựng cấu hình',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.phone),
          label: 'Hỗ trợ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Giỏ hàng',
        ),
      ],
    );
  }
} 