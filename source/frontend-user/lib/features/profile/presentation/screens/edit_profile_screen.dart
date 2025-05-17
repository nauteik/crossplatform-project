import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json, jsonDecode, jsonEncode, utf8;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/api_constants.dart';
import '../../data/repositories/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isUploadingImage = false;

  // User data
  String _id = '';
  String _username = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _rank = '';
  String _gender = '';
  int _totalSpend = 0;
  String _avatarUrl = '';
  DateTime? _birthday;
  File? _avatarImage;
  int _loyaltyPoints = 0;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();

  // Thêm ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Thêm repository vào class
  final UserRepository _userRepository = UserRepository();

  // Thêm danh sách giới tính
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In tất cả các keys trong SharedPreferences để debug
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('SharedPreferences keys: ${prefs.getKeys()}');

      // 1. Tải dữ liệu cơ bản từ SharedPreferences
      String? userId = prefs.getString('userId');
      String? userData = prefs.getString('user_data');

      print('userId from SharedPreferences: $userId');
      print('userData available: ${userData != null}');

      if (userData != null && userData.isNotEmpty) {
        try {
          // Decode chuỗi JSON với UTF-8 rõ ràng
          final data = json.decode(userData);
          print('Decoded user data: ${data.keys}');

          if (data != null) {
            setState(() {
              _id = data['id'] ?? userId ?? '';
              _username = data['username'] ?? data['name'] ?? 'Người dùng';
              _name = data['name'] ?? 'Chưa cập nhật';
              _email = data['email'] ?? 'Chưa cập nhật';
              _phone = data['phone'] ?? 'Chưa cập nhật';
              _rank = data['rank'] ?? 'Bronze';
              _gender = data['gender'] ?? '';
              _totalSpend = data['totalSpend'] ?? 0;
              _avatarUrl = data['avatar'] ?? '';
              _loyaltyPoints = data['loyaltyPoints'] ?? 0;

              if (data['birthday'] != null) {
                if (data['birthday'] is String) {
                  _birthday = DateTime.tryParse(data['birthday']);
                } else if (data['birthday'] is int) {
                  _birthday =
                      DateTime.fromMillisecondsSinceEpoch(data['birthday']);
                }
              }

              _nameController.text = _name != 'Chưa cập nhật' ? _name : '';
              _emailController.text = _email != 'Chưa cập nhật' ? _email : '';
              _phoneController.text = _phone != 'Chưa cập nhật' ? _phone : '';

              if (_birthday != null) {
                _birthdayController.text =
                    DateFormat('dd/MM/yyyy').format(_birthday!);
              }
            });
          }
        } catch (e) {
          print('Error parsing user data JSON: $e');
        }
      } else {
        print('No user data found in SharedPreferences');
      }

      // 2. Nếu có ID người dùng, gọi API để lấy thông tin mới nhất
      String? actualUserId = _id.isNotEmpty ? _id : userId;
      if (actualUserId != null && actualUserId.isNotEmpty) {
        setState(() {
          _id = actualUserId;
        });
        await _fetchUserDetails();
      } else {
        print('No user ID found, cannot fetch user details');
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin người dùng: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Cập nhật phương thức _fetchUserDetails để bao gồm thêm thông tin
  Future<void> _fetchUserDetails() async {
    try {
      print('Fetching user details for ID: $_id');
      if (_id.isEmpty) {
        print('Cannot fetch details: empty user ID');
        return;
      }

      final userDetails = await _userRepository.getCurrentUserDetails();
      print('User details fetched: ${userDetails != null}');

      if (userDetails != null) {
        setState(() {
          // Sử dụng giá trị mặc định tiếng Việt đúng encoding
          _name = userDetails['name'] ?? 'Chưa cập nhật';
          _email = userDetails['email'] ?? 'Chưa cập nhật';
          _phone = userDetails['phone'] ?? 'Chưa cập nhật';
          _rank = userDetails['rank'] ?? 'Bronze';
          _gender = userDetails['gender'] ?? '';
          _totalSpend = userDetails['totalSpend'] ?? 0;
          _avatarUrl = userDetails['avatar'] ?? '';

          // Xử lý ngày sinh
          if (userDetails['birthday'] != null) {
            if (userDetails['birthday'] is String) {
              _birthday = DateTime.tryParse(userDetails['birthday']);
            } else if (userDetails['birthday'] is int) {
              _birthday =
                  DateTime.fromMillisecondsSinceEpoch(userDetails['birthday']);
            }

            if (_birthday != null) {
              _birthdayController.text =
                  DateFormat('dd/MM/yyyy').format(_birthday!);
            }
          }
          _loyaltyPoints = userDetails['loyaltyPoints'] ?? 0;

          // Chỉ cập nhật controllers khi có giá trị thực sự
          if (_name != 'Chưa cập nhật') _nameController.text = _name;
          if (_email != 'Chưa cập nhật') _emailController.text = _email;
          if (_phone != 'Chưa cập nhật') _phoneController.text = _phone;
        });

        // Cập nhật SharedPreferences
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Tạo đối tượng dữ liệu người dùng mới
          final userData = {
            'id': _id,
            'username': _username,
            'name': _name,
            'email': _email,
            'phone': _phone,
            'rank': _rank,
            'gender': _gender,
            'totalSpend': _totalSpend,
            'avatar': _avatarUrl,
          };

          if (_birthday != null) {
            userData['birthday'] = _birthday!.toIso8601String();
          }

          // Encode với UTF-8 và lưu vào SharedPreferences
          final encodedJson = jsonEncode(userData);
          await prefs.setString('user_data', encodedJson);
          print('User data saved to SharedPreferences');
        } catch (e) {
          print('Error saving to SharedPreferences: $e');
        }
      } else {
        print('No user details returned from repository');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  // Upload avatar
  Future<void> _uploadAvatar() async {
    if (_avatarImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tính năng này chưa được hỗ trợ trên web')),
        );
        return;
      }

      // Gọi API để upload ảnh đại diện
      final uploadedUrl =
          await _userRepository.uploadAvatar(_id, _avatarImage!);
      if (uploadedUrl != null) {
        setState(() {
          _avatarUrl = uploadedUrl;
        });

        // Cập nhật SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDataStr = prefs.getString('user_data');

        if (userDataStr != null) {
          final data = jsonDecode(userDataStr);
          data['avatar'] = uploadedUrl;

          // Cập nhật các trường khác để đảm bảo dữ liệu nhất quán
          data['name'] = _name;
          data['email'] = _email;
          data['phone'] = _phone;
          data['rank'] = _rank;
          data['loyaltyPoints'] = _loyaltyPoints;

          // Encode với UTF-8
          final encodedJson = jsonEncode(data);
          await prefs.setString('user_data', encodedJson);
        }
      } else {
        throw Exception('Không thể tải lên ảnh đại diện');
      }
    } catch (e) {
      print('Error uploading avatar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải lên ảnh đại diện: $e')),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // Phương thức để chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      // Chỉ định chất lượng và kích thước ảnh khi chọn từ gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        requestFullMetadata: false, // Có thể giúp tránh lấy metadata thừa
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
        print('Image mime type: ${pickedFile.mimeType}');

        // Nếu định dạng không phải là image/jpeg, image/png hoặc image/gif
        // thì chuyển đổi sang image/jpeg
        final File originalFile = File(pickedFile.path);
        File fileToUpload;

        // Kiểm tra nếu file không phải là các định dạng mong muốn
        if (pickedFile.mimeType != 'image/jpeg' &&
            pickedFile.mimeType != 'image/png' &&
            pickedFile.mimeType != 'image/gif') {
          // Có thể xử lý chuyển đổi format ở đây nếu cần
          // Hoặc đơn giản là thông báo cho người dùng
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang xử lý hình ảnh tải lên'),
              duration: Duration(seconds: 2),
            ),
          );

          // Vẫn sử dụng file gốc, nhưng báo trước cho người dùng
          fileToUpload = originalFile;
        } else {
          fileToUpload = originalFile;
        }

        setState(() {
          _avatarImage = fileToUpload;
        });

        // Tự động upload ảnh khi đã chọn
        await _uploadAvatar();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  // Phương thức để chụp ảnh từ camera
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
        });

        // Tự động upload ảnh khi đã chụp
        await _uploadAvatar();
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chụp ảnh: $e')),
      );
    }
  }

  // Hiển thị dialog chọn phương thức lấy ảnh
  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn ảnh đại diện'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hiển thị dialog chọn ngày sinh
  Future<void> _selectBirthday() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _birthday ?? DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        });

    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Chuẩn bị dữ liệu để gửi lên server
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'gender': _gender,
      };

      // Thêm ngày sinh nếu có
      if (_birthday != null) {
        updatedData['birthday'] = _birthday!.toIso8601String();
      }

      // Gọi API để cập nhật thông qua repository
      final success = await _userRepository.updateUserProfile(_id, updatedData);

      if (success) {
        // Cập nhật dữ liệu local với xử lý UTF-8 đúng cách
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDataStr = prefs.getString('user_data');

        if (userDataStr != null) {
          final data = jsonDecode(userDataStr);
          data['name'] = _nameController.text;
          data['email'] = _emailController.text;
          data['phone'] = _phoneController.text;
          data['gender'] = _gender;
          if (_birthday != null) {
            data['birthday'] = _birthday!.toIso8601String();
          }

          // Encode với UTF-8
          final encodedJson = jsonEncode(data);
          await prefs.setString('user_data', encodedJson);
        }

        setState(() {
          _name = _nameController.text;
          _email = _emailController.text;
          _phone = _phoneController.text;
          // gender và birthday đã được cập nhật trước đó
        });

        if (!mounted) return;

        Navigator.pop(context, true); // Quay lại với kết quả thành công
      } else {
        throw Exception('Cập nhật thông tin thất bại');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu thông tin: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserData,
            tooltip: 'Lưu thay đổi',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Thêm '?' thay vì ':'
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar với khả năng chỉnh sửa
                    Stack(
                      children: [
                        _isUploadingImage
                            ? const CircleAvatar(
                                radius: 60,
                                child: CircularProgressIndicator(),
                              )
                            : _buildAvatar(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: InkWell(
                              onTap: _showImageSourceDialog,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Username (not editable)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Tên đăng nhập'),
                        subtitle: Text(_username),
                      ),
                    ),

                    // Thông tin tổng chi tiêu
                    Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.payments, color: Colors.green),
                        title: const Text('Tổng chi tiêu'),
                        subtitle: Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                            decimalDigits: 0,
                          ).format(_totalSpend),
                        ),
                      ),
                    ),

                    // Rank Badge (not editable)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.military_tech,
                            color: Colors.amber),
                        title: const Text('Hạng thành viên'),
                        subtitle: Text(_rank),
                        trailing: _getRankIcon(),
                      ),
                    ),

                    // Loyalty Points (not editable)
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.loyalty, color: Colors.blue),
                        title: const Text('Điểm thưởng'),
                        subtitle: Text('$_loyaltyPoints điểm'),
                        trailing: Text(
                          '${(_loyaltyPoints * 1000).toStringAsFixed(0)} VND',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Thông tin cá nhân',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),

                    // Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Họ tên',
                      icon: Icons.badge,
                      validator: (value) =>
                          value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Vui lòng nhập email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) return null; // Phone is optional
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Số điện thoại phải có 10 chữ số';
                        }
                        return null;
                      },
                    ),

                    // Giới tính
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Giới tính',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        value:
                            _genderOptions.contains(_gender) ? _gender : null,
                        hint: const Text('Chọn giới tính'),
                        items: _genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _gender = newValue!;
                          });
                        },
                      ),
                    ),

                    // Ngày sinh
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: InkWell(
                        onTap: _selectBirthday,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày sinh',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _birthday == null
                                    ? 'Chọn ngày sinh'
                                    : DateFormat('dd/MM/yyyy')
                                        .format(_birthday!),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu thay đổi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saveUserData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    if (_avatarImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_avatarImage!),
      );
    } else if (_avatarUrl.isNotEmpty && _avatarUrl != 'Chưa cập nhật') {
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(_avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading avatar: $exception');
          // Hiển thị avatar mặc định nếu lỗi
          return;
        },
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.blue.shade100,
        child: Text(
          _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
          style: TextStyle(fontSize: 48, color: Colors.blue.shade700),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
        ),
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _getRankIcon() {
    switch (_rank.toLowerCase()) {
      case 'bronze':
      case 'thành viên đồng':
        return const Icon(Icons.workspace_premium, color: Colors.brown);
      case 'silver':
      case 'thành viên bạc':
        return const Icon(Icons.workspace_premium, color: Colors.grey);
      case 'gold':
      case 'thành viên vàng':
        return const Icon(Icons.workspace_premium, color: Colors.amber);
      case 'platinum':
      case 'thành viên bạch kim':
        return const Icon(Icons.diamond, color: Colors.lightBlueAccent);
      default:
        return const Icon(Icons.workspace_premium, color: Colors.brown);
    }
  }
}
