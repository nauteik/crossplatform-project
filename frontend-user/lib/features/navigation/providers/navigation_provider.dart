import 'package:flutter/material.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../build_pc/presentation/screens/build_configuration_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class NavigationProvider extends ChangeNotifier {
  Widget _currentScreen;
  int _currentIndex = 0;
  List<Widget> _screens = [];
  
  NavigationProvider({Widget? initialScreen}) 
      : _currentScreen = initialScreen ?? const HomeScreen() {
    _initScreens();
  }
  
  void _initScreens() {
    _screens = [
      const HomeScreen(),
      const BuildConfigurationScreen(),
      const ProfileScreen(),
    ];
    _currentScreen = _screens[0];
  }
  
  Widget get currentScreen => _currentScreen;
  int get currentIndex => _currentIndex;
  
  void setBottomNavIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      _currentIndex = index;
      _currentScreen = _screens[index];
      print("NavigationProvider.setBottomNavIndex called with index: $index, screen: ${_currentScreen.runtimeType}");
      notifyListeners();
    }
  }
  
  void navigateTo(String routeName, Widget screen) {
    print("NavigationProvider.navigateTo called with routeName: $routeName");
    _currentScreen = screen;
    notifyListeners();
  }
  
  void setCurrentScreen(Widget screen) {
    print("NavigationProvider.setCurrentScreen called with screen: ${screen.runtimeType}");
    
    // Kiểm tra nếu màn hình mới là một trong các tab chính
    for (int i = 0; i < _screens.length; i++) {
      if (_screens[i].runtimeType == screen.runtimeType) {
        _currentIndex = i;
        _currentScreen = _screens[i];
        notifyListeners();
        return;
      }
    }
    
    // Nếu không phải tab chính, chỉ cập nhật màn hình hiện tại
    _currentScreen = screen;
    notifyListeners();
  }
}