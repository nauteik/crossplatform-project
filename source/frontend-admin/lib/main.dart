import 'package:admin_interface/admin_sidebar.dart';
import 'package:admin_interface/providers/auth_provider.dart';
import 'package:admin_interface/features/login/screens/login_screen.dart';
import 'package:admin_interface/providers/coupon_provider.dart';
import 'package:admin_interface/providers/user_provider.dart';
import 'package:admin_interface/repository/coupon_repository.dart';
import 'package:admin_interface/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:admin_interface/screens_controller.dart';
import 'package:provider/provider.dart';
import 'package:admin_interface/providers/product_provider.dart';
import 'package:admin_interface/providers/brand_provider.dart';
import 'package:admin_interface/providers/product_type_provider.dart';

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
        ChangeNotifierProvider(
          create: (context) => BrandProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductTypeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CouponProvider(),
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

// Wrapper to handle authentication state
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
    // Defer the check to after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
    if (mounted) {
      setState(() {
        _checking = false;
      });
    }
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

    // Get auth provider but DON'T listen to changes here
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      return const Admin();
    } else {
      return const LoginScreen();
    }
  }
}

// ADMIN LANDING PAGE
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
    // Get auth provider to check login state
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      // Redirect to login if not logged in
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
                }),
          )
        ],
      ),
    );
  }
}
