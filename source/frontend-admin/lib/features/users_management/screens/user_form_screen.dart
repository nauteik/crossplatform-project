import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:admin_interface/models/user_model.dart';
import 'package:admin_interface/providers/user_provider.dart';

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
  final _passwordController = TextEditingController(); // Only used for adding or changing password
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  int _selectedRole = 0; // Default to user role (adjust based on your User model/API)
  String? _selectedGender; // Nullable gender
  DateTime? _selectedBirthday; // Nullable birthday

  File? _avatarImageFile;
  String? _avatarPreviewUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If editing, populate the form fields with the user's data
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
    _addressController.dispose();
    super.dispose();
  }

    void _populateForm(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    // Password controller is intentionally NOT populated for security
    _usernameController.text = user.username ?? '';
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';

    // --- FIX START ---
    // Handle the specific case where gender is "Chưa cập nhật" from backend
    if (user.gender != null && user.gender != "Chưa cập nhật") {
       _selectedGender = user.gender;
    } else {
       _selectedGender = null; // Treat "Chưa cập nhật" or null from backend as unselected
    }
    // --- FIX END ---

    // Ensure role is one of the valid options (0 or 1)
    _selectedRole = (user.role == 0 || user.role == 1) ? user.role : 0; // Default to 0 if unexpected value


    _selectedBirthday = user.birthday;

    // Set avatar preview URL
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      // Assume avatar URL can be used directly or processed by an ImageHelper
       // If using ImageHelper, replace user.avatar! with ImageHelper.getUserAvatar(user.avatar!)
      _avatarPreviewUrl = user.avatar!; // Using direct URL from model
    }
  }

  Future<void> _pickAvatarImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          // On web, pickedFile.path is a temporary URL. On mobile/desktop, it's a file path.
          _avatarPreviewUrl = pickedFile.path;
          // On mobile/desktop, create a File object. On web, this is not needed/possible for upload via multipart.
          if (!kIsWeb) {
            _avatarImageFile = File(pickedFile.path);
          } else {
             // For web, the XFile itself is often used for upload
             // You might need to store the XFile if your upload method requires it
             // For simplicity here, we'll assume the provider handles web upload from path/XFile.
             // A more robust web solution might involve sending bytes.
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Lỗi khi chọn ảnh đại diện: $e')),
         );
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime initialDate = _selectedBirthday ?? DateTime.now();
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedBirthday) {
      setState(() {
        _selectedBirthday = pickedDate;
      });
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserManagementProvider>(context, listen: false);
        final Map<String, dynamic> userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'username': _usernameController.text.isEmpty ? null : _usernameController.text, // Send null if empty
          'phone': _phoneController.text.isEmpty ? null : _phoneController.text, // Send null if empty
          'address': _addressController.text.isEmpty ? null : _addressController.text, // Send null if empty
          'gender': _selectedGender, // Can be null
          'birthday': _selectedBirthday?.toIso8601String(), // Format date to ISO 8601 string or null
          'role': _selectedRole,
          // avatar, rank, totalSpend are typically handled by the backend
        };

        // Only include password if it's being set/changed
        if (_passwordController.text.isNotEmpty) {
          userData['password'] = _passwordController.text;
        }

        bool success;
        // Save user
        if (widget.isEditing && widget.user != null) {
          success = await userProvider.updateUser(
            widget.user!.id,
            userData,
          );
           success = await userProvider.updateUser(widget.user!.id, userData);

        } else {
           success = await userProvider.addUser(userData);
        }

        if (context.mounted) {
           if (success) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(widget.isEditing
                     ? 'Cập nhật người dùng thành công!'
                     : 'Thêm người dùng mới thành công!'),
                 backgroundColor: Colors.green,
               ),
             );

             // Quay lại màn hình danh sách và fetch lại data
             Navigator.of(context).pop(true); // Trả về true để báo hiệu thành công
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
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Đã xảy ra lỗi: $e'),
               backgroundColor: Colors.red,
             ),
           );
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
    // Format date for display
    final birthdayDisplay = _selectedBirthday == null
        ? 'Chọn ngày sinh'
        : DateFormat('dd/MM/yyyy').format(_selectedBirthday!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _avatarPreviewUrl != null
                                ? (kIsWeb || _avatarImageFile == null
                                   ? NetworkImage(_avatarPreviewUrl!) // Use NetworkImage for web or existing URL
                                   : FileImage(_avatarImageFile!) as ImageProvider // Use FileImage for picked file on non-web
                                )
                                : null, // No image yet
                            child: _avatarPreviewUrl == null && _avatarImageFile == null
                                ? Icon(Icons.account_circle, size: 60, color: Colors.grey[700])
                                : null,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _pickAvatarImage,
                            icon: const Icon(Icons.photo_camera),
                            label: Text(_avatarPreviewUrl == null ? 'Chọn ảnh đại diện' : 'Đổi ảnh đại diện'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Basic Info
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
                         // Basic email format validation
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                           return 'Email không hợp lệ';
                         }
                        return null;
                      },
                      // Email might not be editable if it's the primary key/identifier
                      readOnly: widget.isEditing, // Consider making email read-only when editing
                    ),
                    const SizedBox(height: 16),

                    // Password field - only required for adding or if user intends to change
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: widget.isEditing ? 'Mật khẩu mới (để trống nếu không đổi)' : 'Mật khẩu',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (!widget.isEditing && (value == null || value.isEmpty)) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        // Add password strength validation if needed
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
                       keyboardType: TextInputType.phone,
                     ),
                     const SizedBox(height: 16),

                     TextFormField(
                       controller: _addressController,
                       decoration: const InputDecoration(
                         labelText: 'Địa chỉ (Tùy chọn)',
                         border: OutlineInputBorder(),
                       ),
                       maxLines: 2,
                     ),
                     const SizedBox(height: 16),

                     // Gender Dropdown
                     DropdownButtonFormField<String>(
                       decoration: const InputDecoration(
                         labelText: 'Giới tính (Tùy chọn)',
                         border: OutlineInputBorder(),
                       ),
                       value: _selectedGender,
                       hint: const Text('Chọn giới tính'),
                       items: const [
                         DropdownMenuItem(value: 'Male', child: Text('Nam')),
                         DropdownMenuItem(value: 'Female', child: Text('Nữ')),
                         DropdownMenuItem(value: 'Other', child: Text('Khác')),
                       ],
                       onChanged: (String? newValue) {
                         setState(() {
                           _selectedGender = newValue;
                         });
                       },
                     ),
                     const SizedBox(height: 16),

                     // Birthday Picker
                     InkWell(
                       onTap: () => _selectBirthday(context),
                       child: InputDecorator(
                         decoration: const InputDecoration(
                           labelText: 'Ngày sinh (Tùy chọn)',
                           border: OutlineInputBorder(),
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(birthdayDisplay),
                             const Icon(Icons.calendar_today),
                           ],
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),

                    // Role Dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Vai trò',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedRole,
                      items: const [
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
                      validator: (value) {
                         if (value == null) {
                           return 'Vui lòng chọn vai trò';
                         }
                         return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoading ? null : _saveUser, // Disable button while loading
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