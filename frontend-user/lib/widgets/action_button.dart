import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/screen_controller.dart';
import 'popup_menu_account.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ActionButton extends StatefulWidget {
  final Function(Widget) onPageChange;

  const ActionButton({
    super.key,
    required this.onPageChange,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  static final ThemeData _theme = ThemeData(
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    ),
  );

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didUpdateWidget(ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkLoginStatus();
  }

  // This runs after each build to check if login state changed
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    print(
        "Checking login status: token = ${token != null ? 'exists' : 'null'}");

    if ((token != null) != _isLoggedIn) {
      print("Login state changed: ${_isLoggedIn} -> ${token != null}");
      setState(() {
        _isLoggedIn = token != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _theme,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: InkWell(
              onTap: () {
                ScreenController.setPageBody('Xây dựng cấu hình');
                widget.onPageChange(ScreenController.getPage());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.screwdriverWrench),
                  Text(
                    "Xây dựng cấu hình",
                    style: _theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: InkWell(
              onTap: () {
                ScreenController.setPageBody('Hỗ trợ');
                widget.onPageChange(ScreenController.getPage());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone),
                  Text(
                    "Hỗ trợ",
                    style: _theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: InkWell(
              onTap: () {
                ScreenController.setPageBody('Giỏ hàng');
                widget.onPageChange(ScreenController.getPage());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart),
                  Text(
                    "Giỏ hàng",
                    style: _theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: _isLoggedIn
                ? PopupMenuAccount(onPageChange: widget.onPageChange)
                : InkWell(
                    onTap: () {
                      ScreenController.setPageBody('LOGIN');
                      widget.onPageChange(ScreenController.getPage());
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login),
                        Text(
                          "Đăng nhập",
                          style: _theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
