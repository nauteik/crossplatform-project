import 'package:admin_interface/models/user_model.dart';
import 'package:admin_interface/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

// --- Giao diện User Management ---
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  _UsersManagementScreenState createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường nhập liệu trong form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _totalSpendController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  String? _selectedGender;
  String? _selectedRank;
  int? _selectedRoleInt;

  // Các giá trị cố định cho dropdown phải khớp với backend
  final List<String> _genders = ['Nam', 'Nữ', 'Khác', 'Chưa cập nhật'];
  final List<String> _ranks = ['Thành viên đồng', 'Thành viên bạc', 'Thành viên vàng', 'Thành viên kim cương'];
  final Map<int, String> _roleMap = {0: 'user', 1: 'admin'};

  User? _editingUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _avatarController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _totalSpendController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  // Hàm reset giá trị của controllers và selected values
  void _resetControllers({User? user}) {
    _emailController.text = user?.email ?? '';
    _usernameController.text = user?.username ?? '';
    _passwordController.text = '';
    _avatarController.text = user?.avatar ?? '';
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _addressController.text = user?.address ?? '';
    _totalSpendController.text = user?.totalSpend?.toString() ?? '0';
    _birthdayController.text = user?.birthday != null ? DateFormat('dd/MM/yyyy').format(user!.birthday!) : '';
    
    // Đảm bảo giá trị gender và rank chỉ được đặt nếu chúng tồn tại trong danh sách
    _selectedGender = user?.gender != null && _genders.contains(user!.gender) ? user.gender : null;
    _selectedRank = user?.rank != null && _ranks.contains(user!.rank) ? user.rank : null;
    _selectedRoleInt = user?.role ?? 0;
  }

  // --- Hàm hiển thị Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdayController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_birthdayController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- Hàm hiển thị Dialog Form (Thêm/Sửa) ---
  void _showUserFormDialog({User? user}) {
    _editingUser = user;
    _resetControllers(user: user);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(user == null ? 'Thêm Người Dùng Mới' : 'Sửa Thông Tin Người Dùng'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập Email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập Username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: user == null ? 'Mật khẩu' : 'Mật khẩu (Để trống nếu không đổi)',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (user == null && (value == null || value.isEmpty)) {
                            return 'Vui lòng nhập Mật khẩu';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Họ Tên'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập Họ Tên';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Số Điện Thoại'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Địa Chỉ'),
                      ),
                      TextFormField(
                        controller: _avatarController,
                        decoration: const InputDecoration(labelText: 'URL Ảnh Đại Diện'),
                        keyboardType: TextInputType.url,
                      ),
                      TextFormField(
                        controller: _birthdayController,
                        decoration: InputDecoration(
                          labelText: 'Ngày Sinh (dd/MM/yyyy)',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        readOnly: true,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: 'Giới Tính'),
                        items: _genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRank,
                        decoration: const InputDecoration(labelText: 'Cấp Bậc'),
                        items: _ranks.map((String rank) {
                          return DropdownMenuItem<String>(
                            value: rank,
                            child: Text(rank),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRank = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalSpendController,
                        decoration: const InputDecoration(labelText: 'Tổng Tiền Đã Chi Tiêu (int)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Vui lòng nhập số nguyên hợp lệ';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedRoleInt,
                        decoration: const InputDecoration(labelText: 'Vai Trò'),
                        items: _roleMap.entries.map((MapEntry<int, String> entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRoleInt = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn vai trò';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final provider = Provider.of<UserManagementProvider>(context, listen: false);

                      DateTime? birthdayDateTime;
                      if (_birthdayController.text.isNotEmpty) {
                        try {
                          birthdayDateTime = DateFormat('dd/MM/yyyy').parse(_birthdayController.text);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi định dạng ngày sinh.')),
                          );
                          return;
                        }
                      }

                      final User tempUser = User(
                        id: user?.id ?? '',
                        email: _emailController.text.trim(),
                        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
                        password: null,
                        avatar: _avatarController.text.trim().isEmpty ? null : _avatarController.text.trim(),
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                        gender: _selectedGender,
                        birthday: birthdayDateTime,
                        rank: _selectedRank,
                        totalSpend: int.tryParse(_totalSpendController.text.trim()) ?? 0,
                        role: _selectedRoleInt ?? 0,
                      );

                      final Map<String, dynamic> userData = tempUser.toJson();

                      if (_passwordController.text.isNotEmpty) {
                        userData['password'] = _passwordController.text;
                      }

                      bool success;
                      if (_editingUser == null) {
                        success = await provider.addUser(userData);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thêm người dùng thành công!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${provider.errorMessage ?? "Không rõ lỗi"}')),
                          );
                          return;
                        }
                      } else {
                        success = await provider.updateUser(_editingUser!.id, userData);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã cập nhật người dùng thành công!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${provider.errorMessage ?? "Không rõ lỗi"}')),
                          );
                          return;
                        }
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(user == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // --- Hàm xử lý Xóa người dùng ---
  void _confirmDeleteUser(User userToDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa người dùng "${userToDelete.name}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<UserManagementProvider>(context, listen: false);
                bool success = await provider.deleteUser(userToDelete.id);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa người dùng: ${userToDelete.name}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi xóa người dùng: ${provider.errorMessage ?? "Không rõ lỗi"}')),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserManagementProvider>();
    final users = userProvider.users;
    final isLoading = userProvider.isLoading;
    final errorMessage = userProvider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Tài Khoản Người Dùng'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && users.isEmpty
              ? Center(child: Text('Lỗi: $errorMessage\nNhấn vào nút + để thử thêm mới hoặc kéo xuống để tải lại.', textAlign: TextAlign.center,))
              : users.isEmpty
                  ? const Center(child: Text('Không có người dùng nào.'))
                  : RefreshIndicator(
                      onRefresh: () => userProvider.fetchUsers(),
                      child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: user.avatar != null && user.avatar!.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            user.avatar!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Text(
                                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                                style: const TextStyle(color: Colors.white, fontSize: 20),
                                              );
                                            },
                                          ),
                                        )
                                      : Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                          style: const TextStyle(color: Colors.white, fontSize: 20),
                                        ),
                                ),
                                title: Text(user.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${user.email}'),
                                    Text('Vai trò: ${user.roleString}'),
                                    if (user.username != null && user.username!.isNotEmpty) Text('Username: ${user.username!}'),
                                    Text('Mật khẩu: ****'),
                                    if (user.phone != null && user.phone!.isNotEmpty) Text('SĐT: ${user.phone!}'),
                                    if (user.address != null && user.address!.isNotEmpty) Text('Địa chỉ: ${user.address!}'),
                                    if (user.gender != null && user.gender!.isNotEmpty) Text('Giới tính: ${user.gender!}'),
                                    Text('Ngày sinh: ${user.birthdayString}'),
                                    if (user.rank != null && user.rank!.isNotEmpty) Text('Cấp bậc: ${user.rank!}'),
                                    Text('Tổng chi tiêu: ${user.totalSpend ?? 0}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Sửa',
                                      onPressed: () {
                                        _showUserFormDialog(user: user);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Xóa',
                                      onPressed: () {
                                        _confirmDeleteUser(user);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : () {
          _showUserFormDialog();
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm người dùng mới',
        backgroundColor: isLoading ? Colors.grey : Theme.of(context).primaryColor,
      ),
    );
  }
}