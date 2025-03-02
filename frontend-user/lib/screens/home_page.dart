import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../screens/body.dart';
import '../widgets/action_button.dart';
import '../widgets/dropdown_menu.dart';
import '../widgets/curved_navigation_bar.dart';
import '../widgets/leading_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _currentBody = Body.landingPageBody();

  void _updateBody(Widget newBody) {
    setState(() {
      _currentBody = newBody;
    });
  }

  List<Widget>? _buildActions() {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return [
        ActionButton(onPageChange: _updateBody),
        const SizedBox(width: 100),
      ];
    }
    return null;
  }

  Widget _platformSpecificSizedBox(double width) {
  if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return SizedBox(width: width);
  }
  return SizedBox(width: 0);
}
//jjkj
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _platformSpecificSizedBox(100),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomePage()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://images.squarespace-cdn.com/content/v1/5930dc9237c5817c00b10842/1557979868721-ZFEVPV8NS06PZ21ZC174/images.png"),
                      radius: 30,
                    ),
                  ),
                  _platformSpecificSizedBox(20),
                  DropDownMenu(
                    onPageChange: _updateBody,
                  ),
                  _platformSpecificSizedBox(20),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      width: 500,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                  ),
                  _platformSpecificSizedBox(10),
                ],
              ),
            ],
          ),
          actions: _buildActions()),
      body: _currentBody,
      bottomNavigationBar: MyBottomNavigationBar(
        onPageChange: _updateBody,
      ),
    );
  }
}
