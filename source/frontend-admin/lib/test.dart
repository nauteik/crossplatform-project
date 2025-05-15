import 'package:admin_interface/features/home/screens/home_screen.dart';
import 'package:admin_interface/features/statistics/screens/statistics_screen.dart';
import 'package:admin_interface/mock_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Mock Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Cung cấp MockDashboardProvider cho cây widget
      home: ChangeNotifierProvider<MockDashboardProvider>(
        create: (context) => MockDashboardProvider(),
        // lazy: false, // Mock provider tự load data, không cần lazy: false ở đây
        child: Scaffold( // Bọc widget dashboard trong Scaffold
          appBar: AppBar(
            title: const Text('Admin Dashboard Preview (Mock Data)'),
          ),
          body: const HomeScreen(), // Sử dụng widget dashboard của bạn
        ),
      ),
    );
  }
}