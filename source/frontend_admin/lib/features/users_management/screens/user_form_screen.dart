import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend_admin/models/user_model.dart';
import 'package:frontend_admin/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  final bool isEditing;

  const UserFormScreen({
    Key? key,
    this.user,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  int _selectedRole = 0;
  String? _selectedGender;
  DateTime? _selectedBirthday;

  File? _avatarImageFile;
  String? _avatarPreviewUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Nếu đang sửa, điền dữ liệu người dùng vào form
    if (widget.isEditing && widget.user != null) {
      _populateForm(widget.user!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

    void _populateForm(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _usernameController.text = user.username ?? '';
    _phoneController.text = user.phone ?? '';
    if (user.gender != null && user.gender!.trim().toLowerCase() != "chưa cập nhật") {
       _selectedGender = user.gender;
    } else {
       _selectedGender = null;
    }

    // Đảm bảo role hợp lệ (0 hoặc 1)
    _selectedRole = (user.role == 0 || user.role == 1) ? user.role : 0; // Mặc định về 0 nếu không hợp lệ

    _selectedBirthday = user.birthday; // Ngày sinh đã là DateTime?

    // Set URL avatar để preview (nếu có)
    if (user.avatar != null && user.avatar!.isNotEmpty && user.avatar!.toLowerCase() != 'chưa cập nhật') {
      _avatarPreviewUrl = user.avatar!;
    } else {
       _avatarPreviewUrl = null; // Không có avatar hoặc là "Chưa cập nhật"
    }
  }

  Future<void> _pickAvatarImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _avatarPreviewUrl = pickedFile.path;
          if (!kIsWeb) {
            _avatarImageFile = File(pickedFile.path);
          } else {
          }
        });
      }
    } catch (e) {
      // Xử lý lỗi khi chọn ảnh
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Lỗi khi chọn ảnh đại diện: ${e.toString()}')),
         );
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime initialDate = _selectedBirthday ?? DateTime.now(); // Ngày ban đầu hiển thị
    final DateTime firstDate = DateTime(1900); // Giới hạn ngày sớm nhất
    final DateTime lastDate = DateTime.now(); // Giới hạn ngày muộn nhất (không cho chọn tương lai)

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    // Cập nhật ngày sinh nếu người dùng chọn và ngày đó khác ngày hiện tại
    if (pickedDate != null && pickedDate != _selectedBirthday) {
      setState(() {
        _selectedBirthday = pickedDate;
      });
    }
  }

  Future<void> _saveUser() async {
    // Validate form trước khi lưu
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Hiển thị indicator loading
      });

      try {
        final userProvider = Provider.of<UserManagementProvider>(context, listen: false);

        // Tạo Map dữ liệu để gửi lên API
        final Map<String, dynamic> userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          // Gửi null cho các trường tùy chọn nếu người dùng để trống
          'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          'gender': _selectedGender, // Có thể là null
          'birthday': _selectedBirthday?.toIso8601String(),
          'role': _selectedRole,
           'avatar': _avatarImageFile != null ? null : _avatarPreviewUrl,
        };

        // Chỉ thêm mật khẩu vào data nếu đang thêm mới hoặc người dùng nhập mật khẩu mới khi sửa
        if (_passwordController.text.isNotEmpty) {
          userData['password'] = _passwordController.text;
        }

        bool success;
        // Gọi phương thức thêm hoặc sửa người dùng từ provider
        if (widget.isEditing && widget.user != null) {
          // Cập nhật người dùng hiện có
          success = await userProvider.updateUser(
            widget.user!.id,
            userData,
          );

        } else {
           // Thêm người dùng mới
           success = await userProvider.addUser(userData);
        }

        // Hiển thị kết quả và quay lại màn hình danh sách
        if (context.mounted) { // Kiểm tra widget còn tồn tại trước khi sử dụng context
           if (success) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(widget.isEditing
                     ? 'Cập nhật người dùng thành công!'
                     : 'Thêm người dùng mới thành công!'),
                 backgroundColor: Colors.green,
               ),
             );
             // Quay lại màn hình danh sách và truyền true để báo hiệu cần refresh
             Navigator.of(context).pop(true);
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Lỗi: ${userProvider.errorMessage ?? 'Không thể lưu người dùng'}'),
                 backgroundColor: Colors.red,
               ),
             );
           }
        }

      } catch (e) {
        // Xử lý các lỗi ngoại lệ
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Đã xảy ra lỗi: ${e.toString()}'),
               backgroundColor: Colors.red,
             ),
           );
        }
      } finally {
        // Dù thành công hay thất bại, ẩn loading indicator
        if (mounted) { // Kiểm tra widget còn tồn tại trước khi gọi setState
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Format ngày sinh để hiển thị
    final birthdayDisplay = _selectedBirthday == null
        ? 'Chọn ngày sinh'
        : DateFormat('dd/MM/yyyy').format(_selectedBirthday!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading khi đang xử lý
          : SingleChildScrollView( // Cho phép cuộn form
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Gán GlobalKey cho Form
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Picker
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            // Logic hiển thị avatar preview (file mới hoặc URL cũ)
                            backgroundImage: _avatarPreviewUrl != null
                                ? (kIsWeb || _avatarImageFile == null // Trên web hoặc không có file mới -> dùng NetworkImage
                                   ? NetworkImage(_avatarPreviewUrl!) as ImageProvider<Object> // Cast để tránh lỗi type
                                   : FileImage(_avatarImageFile!) as ImageProvider<Object> // Trên mobile/desktop có file mới -> dùng FileImage
                                )
                                : null, // Không có avatar
                            // Hiển thị icon placeholder nếu không có avatar
                            child: _avatarPreviewUrl == null && _avatarImageFile == null
                                ? Icon(Icons.account_circle, size: 60, color: Colors.grey[700])
                                : null,
                          ),
                          const SizedBox(height: 8),
                          // Nút chọn/đổi ảnh đại diện
                          ElevatedButton.icon(
                            onPressed: _pickAvatarImage,
                            icon: const Icon(Icons.photo_camera),
                            label: Text(_avatarPreviewUrl == null ? 'Chọn ảnh đại diện' : 'Đổi ảnh đại diện'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Basic Info - Required Fields
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                         // Regex kiểm tra định dạng email cơ bản
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                           return 'Email không hợp lệ';
                         }
                        return null;
                      },
                      // Email không cho sửa khi edit (thường là khóa chính)
                      readOnly: widget.isEditing,
                       style: widget.isEditing ? const TextStyle(color: Colors.grey) : null, // Làm mờ text khi readOnly
                    ),
                    const SizedBox(height: 16),

                    // Password field - Required khi thêm, tùy chọn khi sửa
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: widget.isEditing ? 'Mật khẩu mới (để trống nếu không đổi)' : 'Mật khẩu',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true, // Ẩn mật khẩu
                      validator: (value) {
                        // Nếu đang thêm mới VÀ mật khẩu rỗng thì báo lỗi
                        if (!widget.isEditing && (value == null || value.isEmpty)) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Optional Fields
                     TextFormField(
                       controller: _usernameController,
                       decoration: const InputDecoration(
                         labelText: 'Username (Tùy chọn)',
                         border: OutlineInputBorder(),
                       ),
                     ),
                     const SizedBox(height: 16),

                     TextFormField(
                       controller: _phoneController,
                       decoration: const InputDecoration(
                         labelText: 'Số điện thoại (Tùy chọn)',
                         border: OutlineInputBorder(),
                       ),
                       keyboardType: TextInputType.phone, // Bàn phím số điện thoại
                     ),
                     const SizedBox(height: 16),

                     // Gender Dropdown
                     DropdownButtonFormField<String>(
                       decoration: const InputDecoration(
                         labelText: 'Giới tính (Tùy chọn)',
                         border: OutlineInputBorder(),
                       ),
                       value: _selectedGender, // Giá trị hiện tại
                       hint: const Text('Chọn giới tính'),
                       items: const [ // Các lựa chọn
                         DropdownMenuItem(value: 'Male', child: Text('Nam')),
                         DropdownMenuItem(value: 'Female', child: Text('Nữ')),
                         DropdownMenuItem(value: 'Other', child: Text('Khác')),
                       ],
                       onChanged: (String? newValue) { // Khi giá trị thay đổi
                         setState(() {
                           _selectedGender = newValue;
                         });
                       },
                     ),
                     const SizedBox(height: 16),

                     // Birthday Picker
                     InkWell(
                       onTap: () => _selectBirthday(context), // Gọi hàm chọn ngày
                       child: InputDecorator( // Dùng InputDecorator để giả lập TextFormField
                         decoration: const InputDecoration(
                           labelText: 'Ngày sinh (Tùy chọn)',
                           border: OutlineInputBorder(),
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(birthdayDisplay), // Hiển thị ngày đã chọn hoặc placeholder
                             const Icon(Icons.calendar_today), // Icon lịch
                           ],
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),

                    // Role Dropdown - Bắt buộc chọn vai trò
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Vai trò',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedRole, // Giá trị hiện tại
                      items: const [ // Các lựa chọn vai trò
                        DropdownMenuItem(value: 0, child: Text('User')),
                        DropdownMenuItem(value: 1, child: Text('Admin')),
                      ],
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        }
                      },
                      validator: (value) { // Validator bắt buộc chọn vai trò
                         if (value == null) {
                           return 'Vui lòng chọn vai trò';
                         }
                         return null;
                      },
                    ),
                    const SizedBox(height: 32), // Khoảng cách trước nút Save

                    // Save Button
                    Center(
                      child: SizedBox( // Bọc trong SizedBox để cố định kích thước nút
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoading ? null : _saveUser, // Disable khi loading
                          child: Text(
                            widget.isEditing ? 'Cập nhật người dùng' : 'Thêm người dùng',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}