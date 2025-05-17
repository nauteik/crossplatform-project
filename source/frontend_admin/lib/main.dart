import 'package:flutter/material.dart';
import 'package:frontend_admin/admin_sidebar.dart';
import 'package:frontend_admin/features/login/screens/login_screen.dart';
import 'package:frontend_admin/providers/auth_provider.dart';
import 'package:frontend_admin/providers/brand_provider.dart';
import 'package:frontend_admin/providers/coupon_provider.dart';
import 'package:frontend_admin/providers/message_provider.dart';
import 'package:frontend_admin/providers/overview_provider.dart';
import 'package:frontend_admin/providers/product_provider.dart';
import 'package:frontend_admin/providers/product_type_provider.dart';
import 'package:frontend_admin/providers/statistics_provider.dart';
import 'package:frontend_admin/providers/tag_provider.dart';
import 'package:frontend_admin/providers/user_provider.dart';
import 'package:frontend_admin/repository/user_repository.dart';
import 'package:frontend_admin/screens_controller.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

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
          create: (context) => ProductTypeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TagProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BrandProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CouponProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StatisticsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OverviewProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MessageProvider>(
          create: (context) => MessageProvider(context.read<AuthProvider>()),
          update: (context, auth, previousMessages) {
            return MessageProvider(auth);
          },
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
