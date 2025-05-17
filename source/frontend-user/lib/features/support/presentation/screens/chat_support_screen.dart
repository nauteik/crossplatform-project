import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/message_model.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/services/websocket_service.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _selectedImages = []; // Có thể là File (mobile) hoặc XFile (web)
  String? _userId;
  final WebSocketService _webSocketService = WebSocketService();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Lấy userId từ AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _userId = authProvider.userId;
      });
      
      _initializeChat();
    });
  }
  
  Future<void> _initializeChat() async {
    if (_userId == null || _userId!.isEmpty) {
      return; // Không làm gì nếu không có userId
    }
    
    final provider = Provider.of<MessageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Lấy admin ID từ server
    await provider.fetchDefaultAdminId();
    
    // Nếu lấy được admin ID, load cuộc hội thoại
    if (provider.adminId != null) {
      await provider.loadConversation(_userId!, provider.adminId!);
      
      // Kết nối WebSocket và đăng ký nhận tin nhắn
      _webSocketService.connect(token: authProvider.token);
      
      // Đăng ký nhận tin nhắn
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_webSocketService.isConnected) {
          print("ChatSupportScreen: Đăng ký nhận tin nhắn cho user $_userId và admin ${provider.adminId}");
          _webSocketService.subscribeToUserMessages(
            _userId!, 
            provider.adminId!,
            (message) {
              print("ChatSupportScreen: Nhận tin nhắn mới, chuyển cho provider xử lý");
              provider.messages; // Truy cập để đảm bảo provider cập nhật
              provider.loadConversation(_userId!, provider.adminId!);
            }
          );
        } else {
          print("ChatSupportScreen: WebSocket không được kết nối, không thể đăng ký");
        }
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        setState(() {
          if (kIsWeb) {
            // Trên web, giữ nguyên XFile
            _selectedImages.addAll(pickedImages);
          } else {
            // Trên mobile, chuyển đổi thành File
            _selectedImages.addAll(pickedImages.map((image) => File(image.path)).toList());
          }
        });
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
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
    if (_userId == null || _userId!.isEmpty) {
      return; // Không gửi tin nhắn nếu không có userId
    }
    
    final content = _messageController.text.trim();
    final provider = context.read<MessageProvider>();
    
    if ((content.isNotEmpty || _selectedImages.isNotEmpty) && provider.adminId != null) {
      // Gửi tin nhắn dựa trên nền tảng
      if (kIsWeb) {
        // Trên web, sử dụng sendWebMessage với XFile
        await provider.sendWebMessage(
          _userId!,
          content,
          _selectedImages.isNotEmpty ? List<XFile>.from(_selectedImages) : null,
        );
      } else {
        // Trên mobile, sử dụng sendMessage với File
        await provider.sendMessage(
          _userId!,
          content,
          _selectedImages.isNotEmpty ? List<File>.from(_selectedImages) : null,
        );
      }
      
      // Nếu không có lỗi, xóa nội dung đã nhập và ảnh đã chọn
      if (provider.errorMessage == null) {
        _messageController.clear();
        setState(() {
          _selectedImages = [];
        });
        
        // Cuộn xuống tin nhắn mới nhất
        _scrollToBottom();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthProvider để cập nhật userId nếu có thay đổi
    final authProvider = Provider.of<AuthProvider>(context);
    if (_userId != authProvider.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _userId = authProvider.userId;
        });
        _initializeChat();
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng'),
      ),
      body: _userId == null || _userId!.isEmpty
          ? _buildLoginPrompt()
          : _buildChatUI(),
    );
  }
  
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.support_agent,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Vui lòng đăng nhập để sử dụng tính năng hỗ trợ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Điều hướng đến trang đăng nhập
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatUI() {
    return Column(
      children: [
        // Hiển thị lỗi nếu có
        Consumer<MessageProvider>(
          builder: (context, provider, child) {
            if (provider.errorMessage != null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red[100],
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => provider.clearError(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        // Tin nhắn
        Expanded(
          child: Consumer<MessageProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.adminId == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Không thể kết nối với dịch vụ hỗ trợ.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeChat,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }
              
              if (provider.messages.isEmpty) {
                return const Center(
                  child: Text('Chưa có tin nhắn nào. Hãy gửi tin nhắn để được hỗ trợ.'),
                );
              }
              
              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  return _buildMessageItem(message);
                },
              );
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
                return _buildSelectedImagePreview(_selectedImages[index], index);
              },
            ),
          ),
        
        // Khung nhập tin nhắn
        Consumer<MessageProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: provider.adminId != null ? _pickImage : null,
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
                      enabled: provider.adminId != null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: provider.adminId != null ? _sendMessage : null,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildMessageItem(Message message) {
    final isFromCurrentUser = message.isFromUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser)
            const CircleAvatar(
              child: Icon(Icons.support_agent),
            ),
          
          if (!isFromCurrentUser) const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromCurrentUser)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        "Quản trị viên",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
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
                                child: Image.network(
                                  ImageHelper.getImage(imageUrl),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / 
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error, size: 40, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.network(
                              ImageHelper.getImage(imageUrl),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / 
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
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
  
  Widget _buildSelectedImagePreview(dynamic image, int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: 80,
          height: 80,
          child: kIsWeb 
              ? FutureBuilder<Uint8List>(
                  future: (image as XFile).readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && 
                        snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                )
              : Image.file(
                  image as File,
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
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 