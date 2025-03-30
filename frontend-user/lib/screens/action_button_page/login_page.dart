// filepath: d:\Ton Duc Thang University\HK6\DesignPattern\Final\design-pattern-final-hkt\frontend-user\lib\auth\login_page.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import '../home_page.dart';
import '../screen_controller.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final Function(Widget)? onPageChange; // Thêm callback này

  LoginPage({this.onPageChange}); // Thêm constructor với callback

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  String? _usernameError;
  String? _passwordError;

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _usernameError = 'Username is required';
      });
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    }

    return isValid;
  }

  void _login() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.loginUser(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // IMPORTANT: Store the token FIRST before navigating
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save the token
      String token = result['token'] ?? "";
      await prefs.setString('jwt_token', token);
      print("Token saved to SharedPreferences: $token");

      if (result['userData'] != null) {
        await prefs.setString('user_data', jsonEncode(result['userData']));
      }

      ScreenController.setPageBody('Home');

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Text('Login Failed'),
              ],
            ),
            content: Text(result['message']),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.blue,
          ),
          SizedBox(height: 40),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('LOGIN'),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Register Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
