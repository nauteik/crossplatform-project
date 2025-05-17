import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../navigation/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  String _username = '';
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  String get username => _username;
  String? get userId => _userId;

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
            _userId = _userData!['id'];
            // Tải thông tin chi tiết người dùng
            await loadUserDetails();
          }
        } catch (e) {
          print('Lỗi khi parse userData: $e');
          await _clearAuthData();
          return;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi khi load trạng thái đăng nhập: $e');
      await _clearAuthData();
    }
  }

  // Phương thức riêng để xóa dữ liệu xác thực, không cần context
  Future<void> _clearAuthData() async {
    _token = null;
    _userData = null;
    _isAuthenticated = false;
    _username = '';

    // Xóa dữ liệu từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    await prefs.remove('userId');

    notifyListeners();
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

  Future<bool> login(
      String username, String password, BuildContext context) async {
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
          final userId = _userData!['id'];
          _userId = userId;
          await prefs.setString('userId', userId);

          // Cập nhật userId cho ChatSupportScreen
          Provider.of<NavigationProvider>(context, listen: false)
              .updateChatUserId(userId);
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

  // Định nghĩa GoogleSignIn - sử dụng webClientId từ strings.xml
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId:
        '72454882219-um2q06itq7th3r62r12dc9nn64vivp8b.apps.googleusercontent.com', // Thêm Web Client ID ở đây
  );

  // Phương thức đăng nhập bằng Google được cập nhật
  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;

      // Đăng xuất trước để đảm bảo hiển thị dialog chọn tài khoản
      await _googleSignIn.signOut();

      print('Starting Google Sign-In process...');

      // Hiển thị dialog chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Người dùng hủy quá trình đăng nhập
        print('Google Sign-In cancelled by user');
        return false;
      }

      print('Google Sign-In successful for user: ${googleUser.email}');
      print('Display name: ${googleUser.displayName}');
      print('Photo URL: ${googleUser.photoUrl}');

      // Lấy token ID
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      print('ID Token available: ${idToken != null}');
      print('Access Token available: ${accessToken != null}');

      if (idToken == null) {
        _errorMessage = 'Không thể lấy token xác thực từ Google';
        notifyListeners();
        return false;
      }

      // Hiển thị phần đầu của token để debug
      print('ID Token (first 20 chars): ${idToken.substring(0, 20)}...');
      print('Sending request to: ${ApiConstants.baseUrl}/auth/login/google');

      // Gửi token ID đến backend để xác thực - SỬA ENDPOINT ĐÚNG
      final response = await http
          .post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'token': idToken}),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Server request timed out');
          return http.Response(
              '{"status":408,"message":"Request timeout"}', 408);
        },
      );

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 200) {
          _token = responseData['data']['token'];
          _userData = responseData['data']['user'];

          // Đảm bảo cập nhật đúng các trường username và userId
          _username = _userData?['username'] ?? googleUser.displayName ?? '';
          _userId = _userData?['id'];
          _isAuthenticated = true;

          // Lưu vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _token!);

          // Lưu userId riêng để đảm bảo nhất quán
          if (_userId != null && _userId!.isNotEmpty) {
            await prefs.setString('userId', _userId!);
          }

          // Lưu dữ liệu người dùng
          await prefs.setString('user_data', jsonEncode(_userData));

          print('Saved to SharedPreferences:');
          print('userId: $_userId');
          print('username: $_username');
          print('isAuthenticated: $_isAuthenticated');

          notifyListeners();
          return true;
        } else {
          _errorMessage =
              responseData['message'] ?? 'Đăng nhập Google thất bại';
        }
      } else if (response.statusCode == 500) {
        try {
          // Thử parse error message từ response body
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Internal Server Error (500)';
        } catch (e) {
          _errorMessage = 'Internal Server Error (500) - Lỗi server nội bộ';
        }
      } else {
        _errorMessage = 'Backend error: ${response.statusCode}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      print('Google Sign-In exception: $e');
      _errorMessage = 'Lỗi đăng nhập Google: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // Đảm bảo đăng xuất khỏi Google trước
      await _googleSignIn.signOut();
      print('Signed out from Google');
    } catch (e) {
      print('Error signing out from Google: $e');
    }

    // Xóa dữ liệu authentication
    await _clearAuthData();
    print('Cleared authentication data');

    // Đặt lại userId rỗng cho ChatSupportScreen
    if (context != null) {
      try {
        Provider.of<NavigationProvider>(context, listen: false)
            .updateChatUserId('');
        print('Reset chat user ID');
      } catch (e) {
        print('Error updating navigation provider: $e');
      }
    }
  }

  Future<void> refreshUserData([BuildContext? context]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataStr = prefs.getString('user_data');

      if (userDataStr != null) {
        _userData = jsonDecode(userDataStr);

        // Cập nhật userId cho ChatSupportScreen
        if (_userData != null && _userData!['id'] != null && context != null) {
          Provider.of<NavigationProvider>(context, listen: false)
              .updateChatUserId(_userData!['id']);
        }

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
          _userData = userData;
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

  // Thiết lập token và userId trực tiếp (hữu ích khi tạo tài khoản tự động)
  Future<void> setTokenAndUserId(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('jwt_token', token);
    await prefs.setString('userId', userId);

    _token = token;
    _userId = userId;
    _isAuthenticated = true;

    notifyListeners();
  }
}
