import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final success = await authProvider.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (success) {
          if (mounted) {
            // Hiển thị thông báo đăng ký thành công
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công! Đang đăng nhập...'),
                duration: Duration(seconds: 2),
              ),
            );
            
            // Đợi 2 giây để người dùng đọc thông báo
            await Future.delayed(const Duration(seconds: 2));
            
            // Tự động đăng nhập
            final loginSuccess = await authProvider.login(
              _emailController.text.trim(),
              _passwordController.text,
            );
            
            // Kiểm tra nếu đăng nhập thành công và widget vẫn còn mounted
            if (loginSuccess && mounted) {
              // Pop màn hình đăng ký (quay về màn hình đăng nhập)
              Navigator.pop(context);
              // Tiếp tục pop màn hình đăng nhập (quay về màn hình trước đó)
              Navigator.pop(context);
            } else if (mounted) {
              // Nếu đăng nhập thất bại, chỉ quay về màn hình đăng nhập
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),
              );
            }
          }
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Đăng ký thất bại'),
                    ],
                  ),
                  content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Vui lòng nhập email hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
