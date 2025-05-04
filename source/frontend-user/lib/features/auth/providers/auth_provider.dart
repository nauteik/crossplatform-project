import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/services/auth_service.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  String _username = '';

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  String get username => _username;
  String? get userId => _userData?['id'] as String?;

  AuthProvider() {
    _loadAuthState();
  }
  //
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('jwt_token');
      final userDataString = prefs.getString('user_data');

      if (_token != null && userDataString != null) {
        _isAuthenticated = true;
        try {
          _userData = jsonDecode(userDataString);
          _username = _userData?['username'] ?? '';

          // Kiểm tra và lưu lại userId nếu chưa có
          if (_userData != null && _userData!['id'] != null) {
            await prefs.setString('userId', _userData!['id']);

            // Tải thông tin chi tiết người dùng
            await loadUserDetails();
          }
        } catch (e) {
          print('Lỗi khi parse userData: $e');
          await logout();
          return;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi khi load trạng thái đăng nhập: $e');
      await logout();
    }
  }

  // Thêm phương thức để kiểm tra và làm mới token nếu cần
  Future<bool> refreshTokenIfNeeded() async {
    try {
      // Logic để làm mới token nếu backend có hỗ trợ
      // Ví dụ: gọi API refresh token

      return true;
    } catch (e) {
      print('Lỗi khi làm mới token: $e');
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _errorMessage = null;
      final authService = AuthService();
      final result = await authService.login(username, password);

      if (result['success']) {
        _token = result['token'];
        _userData = result['user'];
        _username = _userData?['username'] ?? username;
        _isAuthenticated = true;

        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        // Lưu userId vào SharedPreferences
        if (_userData != null && _userData!['id'] != null) {
          await prefs.setString('userId', _userData!['id']);
        }

        if (_userData != null) {
          await prefs.setString('user_data', jsonEncode(_userData));
        }

        // Tải thông tin chi tiết người dùng
        await loadUserDetails();

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng nhập thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _errorMessage = null;
      final authService = AuthService();
      final result = await authService.register(username, email, password);
      if (result['success']) {
        // Đăng ký thành công, có thể tự động đăng nhập
        // hoặc để người dùng đăng nhập
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng ký thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile', 'openid'],
  //   clientId:
  //       '72454882219-um2q06itq7th3r62r12dc9nn64vivp8b.apps.googleusercontent.com', // Replace with the correct clientId from Google Cloud Console
  // );

  // // Phương thức đăng nhập bằng Google
  // Future<bool> signInWithGoogle() async {
  //   try {
  //     _errorMessage = null;

  //     // Hiển thị dialog chọn tài khoản Google
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  //     if (googleUser == null) {
  //       // Người dùng hủy quá trình đăng nhập
  //       return false;
  //     }

  //     // Lấy token ID
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final String? idToken = googleAuth.idToken;
  //     final String? accessToken = googleAuth.accessToken;
  //     print('accessToken: $accessToken'); // Debug print to see accessToken
  //     print('idToken: $idToken'); // Debug print to see idToken
  //     if (idToken == null) {
  //       _errorMessage = 'Không thể lấy token xác thực từ Google';
  //       notifyListeners();
  //       return false;
  //     }

  //     // Gửi token ID đến backend để xác thực
  //     // Lưu ý API endpoint không thay đổi - backend sẽ xử lý bằng OAuth2AuthenticationAdapter
  //     final response = await http.post(
  //       Uri.parse('${ApiConstants.baseApiUrl}/api/auth/login/google'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'token': idToken}),
  //     );
  //     if (response.statusCode != 200) {
  //       _errorMessage = 'Backend error: ${response.statusCode}';
  //       notifyListeners();
  //       return false;
  //     }

  //     final responseData = jsonDecode(response.body);

  //     // Xử lý response như trước
  //     if (response.statusCode == 200 && responseData['status'] == 200) {
  //       _token = responseData['data']['token'];
  //       _userData = responseData['data']['user'];
  //       _username = _userData?['name'] ?? googleUser.displayName ?? '';
  //       _isAuthenticated = true;

  //       // Lưu vào SharedPreferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('jwt_token', _token!);
  //       await prefs.setString('user_data', jsonEncode(_userData));

  //       notifyListeners();
  //       return true;
  //     } else {
  //       // Đăng nhập thất bại
  //       _errorMessage = responseData['message'] ?? 'Đăng nhập Google thất bại';
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _errorMessage = 'Lỗi đăng nhập Google: $e';
  //     notifyListeners();
  //     return false;
  //   }
  // }

  Future<void> logout() async {
    _token = null;
    _userData = null;
    _isAuthenticated = false;
    _username = '';

    // Xóa dữ liệu từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    await prefs.remove('userId'); // Thêm dòng này

    notifyListeners();
  }

  Future<void> refreshUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataStr = prefs.getString('user_data');

      if (userDataStr != null) {
        _userData = jsonDecode(userDataStr);
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  Future<void> _fetchUserDetails(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/get/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final userDetails = responseData['data'];

        // Cập nhật thông tin người dùng đầy đủ
        final prefs = await SharedPreferences.getInstance();
        final userDataJson = prefs.getString('user_data');

        if (userDataJson != null) {
          final userData = json.decode(userDataJson) as Map<String, dynamic>;

          // Kết hợp thông tin cũ với thông tin chi tiết
          userData.addAll({
            'email': userDetails['email'],
            'name': userDetails['name'],
            'phone': userDetails['phone'],
            'address': userDetails['address'],
            'gender': userDetails['gender'],
            'birthday': userDetails['birthday'],
            'rank': userDetails['rank'] ?? 'Bronze',
            'totalSpend': userDetails['totalSpend'] ?? 0,
            'avatar': userDetails['avatar'],
          });

          await prefs.setString('user_data', jsonEncode(userData));
          _userData = userData; // Sửa từ this.userData thành _userData
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  // Thêm phương thức này vào class AuthProvider
  Future<void> loadUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userDataString = prefs.getString('user_data');

      if (token == null || userDataString == null) {
        return;
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      if (userId == null) {
        return;
      }

      await _fetchUserDetails(token, userId);
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng chi tiết: $e');
    }
  }
}
