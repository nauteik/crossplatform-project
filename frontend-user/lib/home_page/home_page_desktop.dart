import 'package:flutter/material.dart';
import 'package:frontend_user/screens/landing_page.dart';
import '../widgets/custom_app_bar.dart';

class HomePageDesktop extends StatefulWidget {
  const HomePageDesktop({super.key});

  @override
  State<HomePageDesktop> createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  Widget _currentBody = LandingPage();

  void _updateBody(Widget newBody) {
    setState(() {
      _currentBody = newBody;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(onPageChange: _updateBody),
      body: SingleChildScrollView(
        child: _currentBody,
      ),
    );
  }
}
