import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_interface/models/user_model.dart';
import 'package:admin_interface/providers/user_provider.dart';
import 'package:admin_interface/features/users_management/screens/user_form_screen.dart'; 

enum UserStatus { initial, loading, loaded, error }

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Placeholder for search state - actual search logic needs provider support
  bool _isSearching = false; 
  late Future<void> _fetchUsersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsersFuture = _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    await Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
       print('Searching for: $query');
    } else {
      _clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
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
              Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const UserFormScreen(),
                ),
              ).then((success) {
                // Nếu trả về true (thêm thành công), fetch lại data
                if (success == true) {
                  setState(() {
                    _fetchUsersFuture = _fetchUsers();
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
          setState(() {
            _fetchUsersFuture = _fetchUsers();
          });
        },
        child: FutureBuilder(
          future: _fetchUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Column(
              children: [
                // Search bar (Placeholder functionality)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm người dùng...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => _searchUsers(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _searchUsers, // Calls placeholder search function
                        child: const Text('Tìm kiếm'),
                      ),
                    ],
                  ),
                ),
                // User list
                Expanded(
                  child: _buildBody(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<UserManagementProvider>(
      builder: (context, userProvider, child) {
        // Map provider state to a simple enum for clarity if needed
        // Or just use provider.isLoading and provider.errorMessage directly
        // final status = userProvider.isLoading ? UserStatus.loading : 
        //               userProvider.errorMessage != null ? UserStatus.error :
        //               userProvider.users.isNotEmpty ? UserStatus.loaded : UserStatus.initial;

        if (userProvider.isLoading || _isSearching) { // Check both provider loading and local searching state
          return const Center(child: CircularProgressIndicator());
        } else if (userProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${userProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    userProvider.fetchUsers(); // Retry fetching users
                  },
                  child: const Text('Thử lại'),
                )
              ],
            ),
          );
        } else if (userProvider.users.isNotEmpty) {
          final users = userProvider.users;
          return _buildUsersTable(users);
        } else { // userProvider.users is empty and no error/loading
           return const Center(
              child: Text('Không có người dùng nào'),
            );
        }

        // Fallback, though covered by above conditions
        // return const Center(child: Text('Vui lòng tải dữ liệu người dùng'));
      },
    );
  }

  Widget _buildUsersTable(List<User> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Avatar')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Tên')),
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('SĐT')),
            DataColumn(label: Text('Địa chỉ')),
            DataColumn(label: Text('Giới tính')),
            DataColumn(label: Text('Ngày sinh')),
            DataColumn(label: Text('Rank')),
            DataColumn(label: Text('Total Spend')),
            DataColumn(label: Text('Vai trò')),
            DataColumn(label: Text('Thao tác')),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.id.length > 8 
                    ? '${user.id.substring(0, 8)}...' 
                    : user.id)),
                 DataCell(
                  // Use Image.network if ImageHelper is available for users, else use Icon
                  user.avatar != null && user.avatar!.isNotEmpty
                      ? Image.network(
                          // Assume a function like ImageHelper.getUserAvatar exists
                           // Or use a direct URL if possible/safe
                           user.avatar!, // Using the direct URL from the model
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Placeholder if image fails or is null/empty
                            return const Icon(Icons.account_circle, size: 40);
                          },
                        )
                      : const Icon(Icons.account_circle, size: 40), // Placeholder icon
                ),
                DataCell(Text(user.email)),
                DataCell(Text(user.name)),
                DataCell(Text(user.username ?? 'N/A')), // Handle nullable username
                DataCell(Text(user.phone ?? 'N/A')), // Handle nullable phone
                DataCell(Text(user.address ?? 'N/A')), // Handle nullable address
                DataCell(Text(user.gender ?? 'N/A')), // Handle nullable gender
                DataCell(Text(user.birthdayString)), // Use the getter from User model
                DataCell(Text(user.rank ?? 'N/A')), // Handle nullable rank
                DataCell(Text('${user.totalSpend ?? 0}')), // Handle nullable totalSpend
                DataCell(Text(user.roleString)), // Use the getter from User model
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min, // Use minimum space
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                           // Navigate to UserFormScreen for editing
                           Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserFormScreen(
                                user: user,
                                isEditing: true,
                              ),
                            ),
                          ).then((_) {
                            // Refresh user list when returning from edit screen
                            Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
                          });
                        },
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, user); // Show delete confirmation dialog
                        },
                        tooltip: 'Xóa',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa người dùng ${user.name} (${user.email})?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                
                // Use the provider to delete the user
                final userProvider = Provider.of<UserManagementProvider>(context, listen: false);
                final success = await userProvider.deleteUser(user.id);
                
                // Show feedback (SnackBar) based on deletion result
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa người dùng thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                   // The provider's deleteUser already removes the user from the list and calls notifyListeners,
                   // so the UI should automatically update. No need to explicitly call fetchUsers unless needed for specific scenarios.
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${userProvider.errorMessage ?? 'Không thể xóa người dùng'}'),
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
}