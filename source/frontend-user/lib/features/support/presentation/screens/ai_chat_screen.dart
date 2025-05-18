import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const GEMINI_API_KEY = 'AIzaSyC-1k-DOXZt3j5r_Eviuy5QHFULy3fwb1k';
const GEMINI_API_URL =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Thêm tin nhắn chào mừng từ AI
    _addBotMessage(
      'Xin chào! Tôi là trợ lý ảo của Shop linh kiện HKT. Bạn cần giúp đỡ gì?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  Future<String> _generateAIResponse(String prompt) async {
    try {
      // Tạo nội dung yêu cầu theo định dạng của Gemini API
      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text': '''
                $prompt

                Hãy trả lời như một nhân viên hỗ trợ cho shop online bán phụ kiện và linh kiện máy tính.
                Trả lời ngắn gọn, lịch sự và thân thiện.
                Nếu được hỏi về sản phẩm cụ thể, hãy gợi ý khách hàng tìm kiếm trên ứng dụng hoặc liên hệ bộ phận hỗ trợ.
                Gợi ý giải pháp cho các vấn đề phổ biến như vận chuyển, đổi trả, thanh toán.
                Sử dụng ngôn ngữ tiếng Việt thân thiện.
                '''
              }
            ]
          }
        ],
        'generation_config': {
          'temperature': 0.7,
          'top_p': 0.95,
          'top_k': 40,
          'max_output_tokens': 1024,
        },
        'safety_settings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      // Gửi yêu cầu đến Gemini API
      final response = await http.post(
        Uri.parse('$GEMINI_API_URL?key=$GEMINI_API_KEY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return 'Xin lỗi, tôi không thể trả lời vào lúc này. Vui lòng thử lại sau.';
      }
    } catch (e) {
      print('Error generating AI response: $e');
      return 'Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.';
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      // Hiển thị tin nhắn "đang nhập..." tạm thời
      int loadingMessageIndex = _messages.length;
      setState(() {
        _messages.add(ChatMessage(
          text: 'Đang suy nghĩ...',
          isUser: false,
          timestamp: DateTime.now(),
          isLoading: true,
        ));
      });
      _scrollToBottom();

      // Gọi API để lấy phản hồi
      final response = await _generateAIResponse(message);

      // Xóa tin nhắn "đang nhập..." và thêm phản hồi thực
      setState(() {
        if (loadingMessageIndex < _messages.length) {
          _messages.removeAt(loadingMessageIndex);
        }
        _addBotMessage(response);
      });
    } catch (e) {
      // Xóa tin nhắn "đang nhập..." nếu có lỗi
      setState(() {
        if (_messages.isNotEmpty && _messages.last.isLoading) {
          _messages.removeLast();
        }
        _addBotMessage(
            'Xin lỗi, có lỗi xảy ra khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.');
      });
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
        title: const Text('Chat với AI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // AI assistant info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shop Online AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Trợ lý ảo hỗ trợ 24/7',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Gợi ý câu hỏi
                  IconButton(
                    icon: const Icon(Icons.tips_and_updates_outlined),
                    onPressed: () {
                      _showSuggestedQuestions();
                    },
                  ),
                  // Input field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập câu hỏi của bạn...',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                  // Send button
                  IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.blue),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final dateFormat = DateFormat('HH:mm');
    final timeString = dateFormat.format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 16,
              child: Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue.shade500
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser ? null : const Radius.circular(0),
                  bottomRight: message.isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isLoading) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: message.isUser
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 10,
                        color: message.isUser
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSuggestedQuestions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Câu hỏi thường gặp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSuggestedQuestion('Làm thế nào để đổi trả hàng?'),
                  _buildSuggestedQuestion(
                      'Có mã giảm giá nào đang áp dụng không?'),
                  _buildSuggestedQuestion('Thời gian giao hàng mất bao lâu?'),
                  _buildSuggestedQuestion('Cách theo dõi đơn hàng đã đặt?'),
                  _buildSuggestedQuestion(
                      'Có hỗ trợ thanh toán qua thẻ tín dụng không?'),
                  _buildSuggestedQuestion(
                      'Chính sách bảo hành sản phẩm như thế nào?'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestedQuestion(String question) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _messageController.text = question;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Text(
          question,
          style: TextStyle(color: Colors.blue.shade700),
        ),
      ),
    );
  }
}

// Lớp đại diện cho một tin nhắn trong cuộc trò chuyện
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });
}
