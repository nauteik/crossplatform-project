// filepath: d:\Ton Duc Thang University\HK6\DesignPattern\Final\design-pattern-final-hkt\frontend-user\lib\auth\login_page.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import '../home_page.dart';
import '../screen_controller.dart';

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

  void _login() {
    // Implement login functionality later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login functionality not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            );
          },
        ),
      ),
      body: Padding(
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
                    // ScreenController.setPageBody('REGISTER');

                    // if (widget.onPageChange != null) {
                    //   widget.onPageChange!(ScreenController.getPage());
                    // } else {
                    //   // Nếu không có callback, hiển thị thông báo
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //         content: Text(
                    //             'Không thể điều hướng: callback onPageChange chưa được cung cấp')),
                    //   );
                    // }
                  },
                  child: Text('Register Now'),
                ),
              ],
            ),
          ],
        ),
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
