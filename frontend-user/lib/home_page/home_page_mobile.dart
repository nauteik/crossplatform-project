import 'package:flutter/material.dart';
import 'package:frontend_user/screens/landing_page.dart';
import '../widgets/curved_navigation_bar.dart';
import '../widgets/custom_app_bar.dart';

class HomePageMobile extends StatefulWidget {
  const HomePageMobile({super.key});

  @override
  State<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> {
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
      bottomNavigationBar: MyBottomNavigationBar(onPageChange: _updateBody),
    );
  }
}
