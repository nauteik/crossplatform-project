import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/utils/image_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/message_model.dart';
import '../../../providers/message_provider.dart';
import '../../../providers/auth_provider.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({Key? key}) : super(key: key);

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  String? _adminId;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Lấy ID admin từ AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Debug để xem thông tin hiện tại
      authProvider.printCurrentAdminInfo();
      
      // Hiển thị userId hiện tại từ SharedPreferences
      _checkCurrentAdminIdFromPrefs();
      
      print('Current Admin ID: ${authProvider.userId}');
      
      setState(() {
        _adminId = authProvider.userId;
      });
      
      // Load danh sách users đã gửi tin nhắn
      if (_adminId != null && _adminId!.isNotEmpty) {
        print('Admin ID set: $_adminId');
        context.read<MessageProvider>().loadUsers(_adminId!).then((_) {
          // In ra thông tin sau khi users được tải
          final users = context.read<MessageProvider>().users;
          print('Loaded ${users.length} users');
          for (var user in users) {
            print('User: ${user.id} - ${user.name}');
          }
        }).catchError((error) {
          print('Error loading users: $error');
        });
        
        context.read<MessageProvider>().loadUnreadCount().catchError((error) {
          print('Error loading unread count: $error');
        });
      } else {
        print('Admin ID is null or empty! Checking SharedPreferences...');
        _checkAdminFromSharedPreferences();
      }
    });
  }
  
  // Hàm kiểm tra và hiển thị id lưu trong SharedPreferences
  Future<void> _checkCurrentAdminIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedAdminId = prefs.getString('admin_id');
      final storedAdminEmail = prefs.getString('admin_email');
      final storedAdminName = prefs.getString('admin_name');
      
      print('------------------------------');
      print('SharedPreferences Admin Info:');
      print('Admin ID: $storedAdminId');
      print('Admin Email: $storedAdminEmail');
      print('Admin Name: $storedAdminName');
      print('------------------------------');
    } catch (e) {
      print('Error checking admin prefs: $e');
    }
  }
  
  // Hàm mới để lấy thông tin admin từ SharedPreferences nếu không có trong AuthProvider
  Future<void> _checkAdminFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedAdminId = prefs.getString('admin_id');
      
      if (storedAdminId != null && storedAdminId.isNotEmpty) {
        print('Retrieved Admin ID from SharedPreferences: $storedAdminId');
        setState(() {
          _adminId = storedAdminId;
        });
        
        // Tải dữ liệu với admin ID từ SharedPreferences
        context.read<MessageProvider>().loadUsers(_adminId!).catchError((error) {
          print('Error loading users with stored admin ID: $error');
        });
        
        context.read<MessageProvider>().loadUnreadCount().catchError((error) {
          print('Error loading unread count: $error');
        });
      } else {
        print('No Admin ID found in SharedPreferences!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xác định ID quản trị viên. Vui lòng đăng nhập lại.')),
        );
      }
    } catch (e) {
      print('Error checking admin from SharedPreferences: $e');
    }
  }
  
  Future<void> _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOut
      );
    }
  }
  
  Future<void> _sendMessage() async {
    final messageProvider = context.read<MessageProvider>();
    final selectedUser = messageProvider.selectedUser;
    
    if (selectedUser != null && _adminId != null) {
      final content = _messageController.text.trim();
      
      if (content.isNotEmpty || _selectedImages.isNotEmpty) {
        try {
          await messageProvider.sendMessage(
            _adminId!,
            selectedUser.id,
            content,
            _selectedImages.isNotEmpty ? _selectedImages : null,
          );
          
          _messageController.clear();
          setState(() {
            _selectedImages = [];
          });
          
          // Cuộn xuống tin nhắn mới nhất
          _scrollToBottom();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng'),
        centerTitle: true,
        actions: [
          // Thêm nút refresh để tải lại dữ liệu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Tải lại dữ liệu',
          ),
        ],
      ),
      body: Row(
        children: [
          // Danh sách users
          SizedBox(
            width: 300,
            child: Consumer<MessageProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.users.isEmpty) {
                  return const Center(child: Text('Không có cuộc hội thoại nào'));
                }
                
                return ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatar != null
                            ? NetworkImage('${user.avatar}')
                            : null,
                        child: user.avatar == null
                            ? Text(user.name[0])
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      selected: provider.selectedUser?.id == user.id,
                      onTap: () {
                        provider.setSelectedUser(user);
                        if (_adminId != null) {
                          provider.loadConversation(user.id, _adminId!);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          const VerticalDivider(width: 1),
          
          // Màn hình chat
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, provider, child) {
                final selectedUser = provider.selectedUser;
                
                if (selectedUser == null) {
                  return const Center(
                    child: Text('Vui lòng chọn một người dùng để bắt đầu trò chuyện'),
                  );
                }
                
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return Column(
                  children: [
                    // Thông tin người dùng
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[200],
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: selectedUser.avatar != null
                                ? NetworkImage('${selectedUser.avatar}')
                                : null,
                            child: selectedUser.avatar == null
                                ? Text(selectedUser.name[0])
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedUser.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(selectedUser.email),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Tin nhắn
                    Expanded(
                      child: provider.messages.isEmpty
                          ? const Center(child: Text('Không có tin nhắn nào'))
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              itemCount: provider.messages.length,
                              itemBuilder: (context, index) {
                                final message = provider.messages[index];
                                return _buildMessageItem(message);
                              },
                            ),
                    ),
                    
                    // Hiển thị ảnh đã chọn
                    if (_selectedImages.isNotEmpty)
                      Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 80,
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    
                    // Khung nhập tin nhắn
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo),
                            onPressed: _pickImage,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageItem(Message message) {
    final isFromCurrentUser = !message.isFromUser; // Admin không phải là isFromUser
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              backgroundImage: Provider.of<MessageProvider>(context, listen: false)
                  .selectedUser?.avatar != null
                  ? NetworkImage('${Provider.of<MessageProvider>(context, listen: false).selectedUser!.avatar}')
                  : null,
              child: Provider.of<MessageProvider>(context, listen: false).selectedUser?.avatar == null
                  ? Text(Provider.of<MessageProvider>(context, listen: false).selectedUser!.name[0])
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.content.isNotEmpty)
                    Text(message.content),
                  
                  // Hiển thị ảnh trong tin nhắn
                  if (message.images.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: message.images.map((imageUrl) {
                        return GestureDetector(
                          onTap: () {
                            // Hiển thị ảnh full size
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Image.network(ImageHelper.getProductImage(imageUrl)),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.network(
                              ImageHelper.getProductImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm dd/MM/yyyy').format(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isFromCurrentUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Hàm để tải lại dữ liệu khi refresh
  Future<void> _refreshData() async {
    try {
      // Hiển thị thông báo đang tải
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải lại dữ liệu...')),
      );
      
      if (_adminId == null || _adminId!.isEmpty) {
        print('Kiểm tra lại ID quản trị viên từ SharedPreferences...');
        await _checkAdminFromSharedPreferences();
      } else {
        print('Tải lại dữ liệu với adminId: $_adminId');
        await context.read<MessageProvider>().loadUsers(_adminId!);
        
        // Nếu đang có cuộc hội thoại, tải lại
        final selectedUser = context.read<MessageProvider>().selectedUser;
        if (selectedUser != null) {
          await context.read<MessageProvider>().loadConversation(selectedUser.id, _adminId!);
        }
        
        await context.read<MessageProvider>().loadUnreadCount();
        
        // Hiển thị thông báo tải thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tải lại dữ liệu thành công')),
        );
      }
    } catch (e) {
      print('Lỗi khi tải lại dữ liệu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
} 