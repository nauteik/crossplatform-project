import 'package:flutter/material.dart';
import 'package:frontend_user/screens/landing_page.dart';
import '../widgets/custom_app_bar.dart';

class HomePageWeb extends StatefulWidget {
  const HomePageWeb({super.key});

  @override
  State<HomePageWeb> createState() => _HomePageWebState();
}

class _HomePageWebState extends State<HomePageWeb> {
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
