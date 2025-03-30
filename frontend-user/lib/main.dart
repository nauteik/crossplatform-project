import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'layout_responsive.dart'; // Nhập trang layout builder
=======
import 'app.dart';
>>>>>>> offical-main

void main() {
  runApp(const MyApp());
}
<<<<<<< HEAD

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Computer Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ResponsiveLayout(),
    );
  }
}
=======
>>>>>>> offical-main
