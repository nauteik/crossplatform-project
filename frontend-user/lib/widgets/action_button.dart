import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/navigation/providers/navigation_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/build_pc/presentation/screens/build_configuration_screen.dart';
import '../features/support/presentation/screens/support_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import 'popup_menu_account.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
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
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
    return Theme(
      data: _theme,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: InkWell(
              onTap: () {
                print("Nút xây dựng cấu hình được nhấn"); // Debug print
                navigationProvider.setCurrentScreen(const BuildConfigurationScreen());
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
                print("Nút hỗ trợ được nhấn"); // Debug print
                navigationProvider.setCurrentScreen(const SupportScreen());
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
                print("Nút giỏ hàng được nhấn"); // Debug print
                navigationProvider.setCurrentScreen(const CartScreen());
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
                ? PopupMenuAccount()
                : InkWell(
                    onTap: () {
                      print("Nút đăng nhập trong ActionButton được nhấn"); // Debug print
                      navigationProvider.setCurrentScreen(const LoginScreen());
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
