import 'package:flutter/material.dart';
import '../../home/presentation/screens/landing_screen.dart';

class NavigationProvider extends ChangeNotifier {
  Widget _currentScreen;
  
  NavigationProvider({Widget? initialScreen}) 
      : _currentScreen = initialScreen ?? const LandingScreen();
  
  Widget get currentScreen => _currentScreen;
  
  void navigateTo(String routeName, Widget screen) {
    print("NavigationProvider.navigateTo called with routeName: $routeName");
    _currentScreen = screen;
    notifyListeners();
  }
  
  void setCurrentScreen(Widget screen) {
    print("NavigationProvider.setCurrentScreen called with screen: ${screen.runtimeType}");
    _currentScreen = screen;
    notifyListeners();
  }
} 