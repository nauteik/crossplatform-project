import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/message_provider.dart';

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
  
  @override
  void initState() {
    super.initState();
    // TODO: Thay thế 'admin-id' bằng ID thực của admin đang đăng nhập
    _adminId = 'admin-id';
    
    // Load danh sách users đã gửi tin nhắn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_adminId != null) {
        context.read<MessageProvider>().loadUsers(_adminId!);
        context.read<MessageProvider>().loadUnreadCount();
      }
    });
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
                                child: Image.network('$imageUrl'),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.network(
                              '$imageUrl',
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
    super.dispose();
  }
} 