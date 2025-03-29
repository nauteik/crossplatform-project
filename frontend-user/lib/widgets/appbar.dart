import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../features/navigation/providers/navigation_provider.dart';
import '../features/home/presentation/screens/home_screen.dart';
import 'action_button.dart';
import 'dropdown_menu.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  List<Widget>? _buildActions(BuildContext context) {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return [
        const ActionButton(),
        const SizedBox(width: 100),
      ];
    }
    return null;
  }

  Widget _platformSpecificSizedBox(double width) {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return SizedBox(width: width);
    }
    return const SizedBox(width: 0);
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
    return AppBar(
      backgroundColor: Colors.blue,
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _platformSpecificSizedBox(100),
              GestureDetector(
                onTap: () {
                  navigationProvider.setCurrentScreen(const HomeScreen());
                },
                child: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    "https://images.squarespace-cdn.com/content/v1/5930dc9237c5817c00b10842/1557979868721-ZFEVPV8NS06PZ21ZC174/images.png"),
                  radius: 30,
                ),
              ),
              _platformSpecificSizedBox(20),
              const DropDownMenu(),
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
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              _platformSpecificSizedBox(10)
            ],
          ),
        ],
      ),
      actions: _buildActions(context),
    );
  }
} 