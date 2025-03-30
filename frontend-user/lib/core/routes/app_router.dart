// core/routes/app_router.dart
import 'package:flutter/material.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String pcGaming = '/products/pc-gaming';
  static const String pcOffice = '/products/pc-office';
  static const String pcGraphics = '/products/pc-graphics';
  static const String monitor = '/products/monitor';
  static const String mouse = '/products/mouse';
  static const String keyboard = '/products/keyboard';
  static const String storage = '/products/storage';
  static const String component = '/products/component';
  static const String buildConfig = '/build-config';
  static const String support = '/support';
  // Định nghĩa các route khác

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget screen;
    
    switch (settings.name) {
      case home:
        screen = Container(); // Sẽ thay bằng LandingScreen
        break;
      case login:
        screen = Container(); // Sẽ thay bằng LoginScreen
        break;
      case register:
        screen = Container(); // Sẽ thay bằng RegisterScreen
        break;
      case cart:
        screen = Container(); // Sẽ thay bằng CartScreen
        break;
      case pcGaming:
        screen = Container(); // Sẽ thay bằng PCGamingScreen
        break;
      case pcOffice:
        screen = Container(); // Sẽ thay bằng PCOfficeScreen
        break;
      case pcGraphics:
        screen = Container(); // Sẽ thay bằng PCGraphicsScreen
        break;
      case monitor:
        screen = Container(); // Sẽ thay bằng MonitorScreen
        break;
      case mouse:
        screen = Container(); // Sẽ thay bằng MouseScreen
        break;
      case keyboard:
        screen = Container(); // Sẽ thay bằng KeyboardScreen
        break;
      case storage:
        screen = Container(); // Sẽ thay bằng StorageScreen
        break;
      case component:
        screen = Container(); // Sẽ thay bằng ComponentScreen
        break;
      case buildConfig:
        screen = Container(); // Sẽ thay bằng BuildConfigScreen
        break;
      case support:
        screen = Container(); // Sẽ thay bằng SupportScreen
        break;
      // Thêm các route khác
      default:
        screen = Container(); // Default screen
        break;
    }
    
    return MaterialPageRoute(builder: (_) => screen);
  }

  static void navigateTo(BuildContext context, String routeName) {
    Widget screen;
    
    switch (routeName) {
      case 'LOGIN':
        screen = Container(); // Sẽ thay bằng LoginScreen
        break;
      case 'REGISTER':
        screen = Container(); // Sẽ thay bằng RegisterScreen
        break;
      case 'HOME':
        screen = Container(); // Sẽ thay bằng LandingScreen
        break;
      case 'CART':
        screen = Container(); // Sẽ thay bằng CartScreen
        break;
      case 'PC GAMING':
        screen = Container(); // Sẽ thay bằng PCGamingScreen
        break;
      case 'PC OFFICE':
        screen = Container(); // Sẽ thay bằng PCOfficeScreen
        break;
      case 'PC GRAPHICS':
        screen = Container(); // Sẽ thay bằng PCGraphicsScreen
        break;
      case 'MONITOR':
        screen = Container(); // Sẽ thay bằng MonitorScreen
        break;
      case 'MOUSE':
        screen = Container(); // Sẽ thay bằng MouseScreen
        break;
      case 'KEYBOARD':
        screen = Container(); // Sẽ thay bằng KeyboardScreen
        break;
      case 'STORAGE':
        screen = Container(); // Sẽ thay bằng StorageScreen
        break;
      case 'COMPONENT':
        screen = Container(); // Sẽ thay bằng ComponentScreen
        break;
      case 'BUILD CONFIG':
        screen = Container(); // Sẽ thay bằng BuildConfigScreen
        break;
      case 'SUPPORT':
        screen = Container(); // Sẽ thay bằng SupportScreen
        break;
      // Thêm các trường hợp khác
      default:
        screen = Container(); // Default screen
        break;
    }
    
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}