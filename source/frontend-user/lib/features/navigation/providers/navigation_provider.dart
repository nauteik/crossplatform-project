import 'package:flutter/material.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../build_pc/presentation/screens/build_configuration_screen.dart';
import '../../product/presentation/screens/product_category_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class NavigationProvider extends ChangeNotifier {
  Widget _currentScreen;
  int _currentIndex = 0;
  List<Widget> _screens = [];
  final List<Widget> _navigationHistory = [];
  
  NavigationProvider({Widget? initialScreen}) 
      : _currentScreen = initialScreen ?? const HomeScreen() {
    _initScreens();
    _navigationHistory.add(_currentScreen);
  }
  
  void _initScreens() {
    _screens = [
      const HomeScreen(),
      const ProductCategoryScreen(),
      const BuildConfigurationScreen(),
      const ProfileScreen(),
    ];
    _currentScreen = _screens[0];
  }
  
  Widget get currentScreen => _currentScreen;
  int get currentIndex => _currentIndex;
  
  /// Dùng để điều hướng giữa các tab chính trong bottom navigation
  void setBottomNavIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      _currentIndex = index;
      _currentScreen = _screens[index];
      
      // Thêm màn hình vào lịch sử
      _navigationHistory.add(_currentScreen);
      
      print("NavigationProvider: Chuyển đến tab $index, màn hình: ${_currentScreen.runtimeType}");
      notifyListeners();
    }
  }
  
  /// Dùng để điều hướng đến các màn hình không nằm trong bottom navigation
  void navigateTo(Widget screen) {
    print("NavigationProvider: Điều hướng đến màn hình ${screen.runtimeType}");
    
    // Kiểm tra nếu màn hình mới là một trong các tab chính
    for (int i = 0; i < _screens.length; i++) {
      if (_screens[i].runtimeType == screen.runtimeType) {
        _currentIndex = i;
        _currentScreen = _screens[i];
        _navigationHistory.add(_currentScreen);
        notifyListeners();
        return;
      }
    }
    
    // Nếu không phải tab chính, chỉ cập nhật màn hình hiện tại
    _currentScreen = screen;
    _navigationHistory.add(_currentScreen);
    notifyListeners();
  }
  
  /// Reset về trang chủ (tab 0) - Hữu ích khi đăng xuất
  void resetToHome() {
    _currentIndex = 0;
    _currentScreen = _screens[0];
    _navigationHistory.clear();
    _navigationHistory.add(_currentScreen);
    print("NavigationProvider: Reset về trang chủ");
    notifyListeners();
  }
  
  /// Quay lại màn hình trước đó nếu có
  bool goBack() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      final previousScreen = _navigationHistory.last;
      
      // Cập nhật currentIndex nếu màn hình trước đó là tab chính
      for (int i = 0; i < _screens.length; i++) {
        if (_screens[i].runtimeType == previousScreen.runtimeType) {
          _currentIndex = i;
          _currentScreen = _screens[i];
          notifyListeners();
          return true;
        }
      }
      
      _currentScreen = previousScreen;
      notifyListeners();
      return true;
    }
    return false;
  }
}