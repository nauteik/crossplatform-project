import 'package:flutter/material.dart';
import 'package:frontend_admin/features/users_management/screens/user_details_dialog.dart';
import 'package:frontend_admin/features/users_management/screens/user_form_screen.dart';
import 'package:frontend_admin/models/user_model.dart';
import 'package:frontend_admin/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<void> _fetchUsersFuture;

  @override
  void initState() {
    super.initState();
    // Bắt đầu fetch dữ liệu khi màn hình khởi tạo
    _fetchUsersFuture = _fetchUsers();

    // Thêm listener cho search controller để lọc khi text thay đổi
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchUsers() async {
    await Provider.of<UserManagementProvider>(
      context,
      listen: false,
    ).fetchUsers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Phương thức được gọi khi text trong search bar thay đổi
  void _onSearchChanged() {
    setState(() {});
  }

  // Phương thức xử lý tìm kiếm (có thể bỏ qua nếu dùng listener)
  void _searchUsers() {
    setState(() {});
  }

  // Phương thức xóa tìm kiếm và hiển thị lại toàn bộ danh sách
  void _clearSearch() {
    _searchController.clear();
  }

  // Phương thức hiển thị dialog chi tiết người dùng
  void _showUserDetailsDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserDetailsDialog(user: user);
      },
    );
  }

  // Phương thức hiển thị dialog xác nhận xóa
  void _showDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa người dùng ${user.name} (${user.email})?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng dialog

                final userProvider = Provider.of<UserManagementProvider>(
                  context,
                  listen: false,
                );
                final success = await userProvider.deleteUser(user.id);

                // Hiển thị phản hồi (SnackBar)
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa người dùng thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Lỗi: ${userProvider.errorMessage ?? 'Không thể xóa người dùng'}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Hàm lọc danh sách người dùng dựa trên query (trong widget)
  List<User> _filterUsers(List<User> users, String query) {
    if (query.isEmpty) {
      return users;
    }

    final lowerCaseQuery = query.toLowerCase().trim();

    return users.where((user) {
      final nameMatch = user.name.toLowerCase().contains(lowerCaseQuery);
      final usernameMatch =
          user.username?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final phoneMatch =
          user.phone?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final emailMatch = user.email.toLowerCase().contains(lowerCaseQuery);

      return nameMatch || usernameMatch || phoneMatch || emailMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Điều hướng đến màn hình thêm người dùng
              Navigator.of(context)
                  .push<bool>(
                    // Push với kết quả trả về bool
                    MaterialPageRoute(
                      builder: (context) => const UserFormScreen(),
                    ),
                  )
                  .then((success) {
                    if (success == true) {
                      setState(() {
                        _fetchUsersFuture = _fetchUsers();
                        _searchController.clear();
                      });
                    }
                  });
            },
            tooltip: 'Thêm người dùng mới',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Khi refresh, fetch lại dữ liệu và xóa search bar
          setState(() {
            _fetchUsersFuture = _fetchUsers();
            _searchController.clear(); // Xóa search bar khi refresh
          });
        },
        // FutureBuilder chờ fetch ban đầu hoàn thành
        child: FutureBuilder(
          future: _fetchUsersFuture,
          builder: (context, snapshot) {
            // Xử lý trạng thái loading/error ban đầu từ _fetchUsersFuture
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Sau khi fetch ban đầu xong, phần còn lại được quản lý bởi Consumer
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm theo tên, username, SĐT...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    )
                                    : null,
                          ),
                          // Listener _onSearchChanged đã trigger lọc khi gõ
                          // onSubmitted: (_) => _searchUsers(), // Có thể bỏ qua nếu dùng listener
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Nút "Tìm kiếm" (có thể bỏ qua nếu dùng listener)
                      ElevatedButton(
                        onPressed: _searchUsers,
                        child: const Text('Tìm kiếm'),
                      ),
                    ],
                  ),
                ),
                // Danh sách người dùng được quản lý bởi Consumer
                Expanded(
                  // Consumer lắng nghe UserManagementProvider
                  child: Consumer<UserManagementProvider>(
                    builder: (context, userProvider, child) {
                      // Xử lý trạng thái loading và error từ provider
                      if (userProvider.isLoading) {
                        // Provider đang loading
                        return const Center(child: CircularProgressIndicator());
                      } else if (userProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lỗi: ${userProvider.errorMessage}',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Xóa search bar và thử fetch lại
                                  _searchController.clear();
                                  userProvider.fetchUsers();
                                },
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Lấy danh sách người dùng gốc từ provider
                      final allUsers = userProvider.users;
                      // Lọc danh sách dựa trên text hiện tại trong search bar
                      final displayedUsers = _filterUsers(
                        allUsers,
                        _searchController.text,
                      );

                      // Hiển thị thông báo nếu danh sách rỗng (toàn bộ hoặc sau khi lọc)
                      if (displayedUsers.isEmpty) {
                        final isSearchActive =
                            _searchController.text.isNotEmpty;
                        return Center(
                          child: Text(
                            isSearchActive
                                ? 'Không tìm thấy người dùng nào trùng khớp.'
                                : 'Không có người dùng nào.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      } else {
                        // Hiển thị danh sách người dùng đã lọc bằng ListView
                        return _buildUsersList(displayedUsers);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Xây dựng ListView item với layout 3 phần mới
  Widget _buildUsersList(List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          // Sử dụng Card cho mỗi item
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng trên cùng: Tên người dùng
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 16, thickness: 1), // Đường phân cách
                // Hàng giữa: Avatar và các thông tin chi tiết còn lại
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[300],
                      // Sử dụng NetworkImage chỉ nếu URL avatar hợp lệ và không phải "Chưa cập nhật"
                      backgroundImage:
                          user.avatar != null &&
                                  user.avatar!.isNotEmpty &&
                                  user.avatar!.toLowerCase() != 'chưa cập nhật'
                              ? NetworkImage(user.avatar!)
                              : null,
                      // Hiển thị icon placeholder nếu không có avatar hợp lệ
                      child:
                          (user.avatar == null ||
                                  user.avatar!.isEmpty ||
                                  user.avatar!.toLowerCase() == 'chưa cập nhật')
                              ? Icon(
                                Icons.account_circle,
                                size: 28,
                                color: Colors.grey[700],
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),

                    // Các thông tin chi tiết khác (ID, Username, Email, SĐT, Vai trò)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${user.id.length > 8 ? '${user.id.substring(0, 8)}...' : user.id}', // Rút gọn ID
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Username: ${user.username ?? 'N/A'}', // Username có thể null
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${user.email}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Hiển thị SĐT
                          Text(
                            'SĐT: ${user.phone ?? 'N/A'}', // SĐT có thể null hoặc "Chưa cập nhật" (đã xử lý trong model)
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 8,
                          ), // Khoảng cách trước Vai trò
                          // Hiển thị Vai trò
                          Text(
                            'Vai trò: ${user.roleString}', // Sử dụng getter roleString
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Bỏ hiển thị Rank và Total Spend ở đây
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16, thickness: 1), // Đường phân cách
                // Hàng cuối cùng: Các nút chức năng
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Căn cuối
                  children: [
                    // Nút Xem Chi tiết
                    TextButton.icon(
                      onPressed: () => _showUserDetailsDialog(user),
                      icon: const Icon(Icons.info_outline, size: 20),
                      label: const Text('Chi tiết'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút Sửa
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder:
                                    (context) => UserFormScreen(
                                      user: user,
                                      isEditing: true,
                                    ),
                              ),
                            )
                            .then((_) {
                              Provider.of<UserManagementProvider>(
                                context,
                                listen: false,
                              ).fetchUsers(); // Refetch toàn bộ
                            });
                      },
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Sửa'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút Xóa
                    TextButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context, user);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Xóa',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
