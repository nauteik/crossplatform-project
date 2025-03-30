import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../screens/home_page.dart';
import 'dropdown_menu.dart';
import 'action_button.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(Widget) onPageChange;

  const MyAppBar({
    super.key,
    required this.onPageChange,
  });

  @override
  Size get preferredSize => const Size.fromHeight(240);

  double _getAppBarHeight(double screenWidth) {
    if (screenWidth <= 600) {
      return 200;
    } else if (screenWidth <= 1000) {
      return 100;
    } else {
      return kToolbarHeight;
    }
  }

  Widget _platformSpecificSizedBox(double width) {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return SizedBox(width: width);
    }
    return SizedBox(width: 0);
  }

  List<Widget>? _buildActions() {
    if (kIsWeb || Platform.isWindows || Platform.isIOS) {
      return [
        ActionButton(onPageChange: onPageChange),
        const SizedBox(width: 100),
      ];
    }
    return null;
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomePage(),
          ),
        );
      },
      child: const CircleAvatar(
        backgroundImage: NetworkImage(
          "https://images.squarespace-cdn.com/content/v1/5930dc9237c5817c00b10842/1557979868721-ZFEVPV8NS06PZ21ZC174/images.png",
        ),
        radius: 30,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return SizedBox(
      height: 40,
      width: 400,
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
    );
  }

  Widget _responsive(BuildContext context, double screenWidth) {
    if (screenWidth <= 600) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogo(context),
              DropDownMenu(
                onPageChange: onPageChange,
              ),
            ],
          ),
          _buildSearchBar(context, screenWidth),
          ...?_buildActions(),
        ],
      );
    } else if (screenWidth <= 1000) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogo(context),
              DropDownMenu(
                onPageChange: onPageChange,
              ),
              _buildSearchBar(context, screenWidth),
            ],
          ),
          ...?_buildActions(),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLogo(context),
          DropDownMenu(
            onPageChange: onPageChange,
          ),
          _buildSearchBar(context, screenWidth),
          ...?_buildActions(),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = _getAppBarHeight(screenWidth);

    return SizedBox(
      height: appBarHeight,
      child: AppBar(
        backgroundColor: Colors.blue,
        flexibleSpace: _responsive(context, screenWidth),
      ),
    );
  }
}
