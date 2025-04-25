import 'package:admin_interface/admin_sidebar.dart';
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
          create: (context) =>
              UserManagementProvider(UserManagementRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider(
          create: (context) => ProductProvider(),
          child: const Admin(),
        ),
      ),
    );
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
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(sidebarXController: sidebarXController),
          Expanded(
              child: AnimatedBuilder(
                  animation: sidebarXController,
                  builder: (context, _) {
                    return navigateToScreen(sidebarXController.selectedIndex);
                  }))
        ],
      ),
    );
  }
}
