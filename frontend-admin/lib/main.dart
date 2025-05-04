import 'package:admin_interface/admin_sidebar.dart';
import 'package:admin_interface/providers/auth_provider.dart';
import 'package:admin_interface/features/login/screens/login_screen.dart';
import 'package:admin_interface/providers/user_provider.dart';
import 'package:admin_interface/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:admin_interface/screens_controller.dart';
import 'package:provider/provider.dart';
import 'package:admin_interface/providers/product_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              UserManagementProvider(UserManagementRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Admin Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const Admin(),
        },
      ),
    );
  }
}

// Wrapper để xử lý trạng thái xác thực
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
    setState(() {
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    return authProvider.isLoggedIn ? const Admin() : const LoginScreen();
  }
}

// Trang chính của Admin
class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final sidebarXController =
      SidebarXController(selectedIndex: 0, extended: true);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái đăng nhập
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      // Chuyển hướng đến trang đăng nhập nếu chưa đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(sidebarXController: sidebarXController),
          Expanded(
            child: AnimatedBuilder(
              animation: sidebarXController,
              builder: (context, _) {
                return navigateToScreen(
                    sidebarXController.selectedIndex, context);
              },
            ),
          )
        ],
      ),
    );
  }
}
