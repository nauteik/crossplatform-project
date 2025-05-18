import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart'; // Đảm bảo import này tồn tại
import 'dart:math' show min;

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
  String _productContext = "";
  bool _isProductDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Thêm tin nhắn chào mừng từ AI
    _addBotMessage(
      'Xin chào! Tôi là trợ lý ảo của Shop linh kiện HKT. Bạn cần giúp đỡ gì?',
    );

    // Tải dữ liệu sản phẩm khi khởi động
    _loadProductData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Tải dữ liệu sản phẩm từ API
  Future<void> _loadProductData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Sử dụng API sản phẩm trực tiếp (phương pháp đáng tin cậy nhất)
      final fallbackResponse = await http.get(
        Uri.parse('${ApiConstants.baseApiUrl}/api/product/products'),
      );

      print("Response status code: ${fallbackResponse.statusCode}");
      print(
          "Response body preview: ${fallbackResponse.body.substring(0, min(100, fallbackResponse.body.length))}...");

      if (fallbackResponse.statusCode == 200) {
        try {
          final fallbackData = jsonDecode(fallbackResponse.body);
          if (fallbackData['status'] == 200 && fallbackData['data'] != null) {
            // Chuyển đổi dữ liệu sản phẩm thành định dạng đơn giản hơn
            final products = fallbackData['data'] as List;

            if (products.isNotEmpty) {
              final simplifiedProducts = products.map((product) {
                // Xử lý trường hợp brand và productType là Map
                String brandName = '';
                String categoryName = '';

                if (product['brand'] != null) {
                  brandName = product['brand']['name'] ?? '';
                }

                if (product['productType'] != null) {
                  categoryName = product['productType']['name'] ?? '';
                }

                // Xử lý trường hợp price có thể là scientific notation (ví dụ: 1.599E7)
                double price = 0;
                if (product['price'] != null) {
                  if (product['price'] is String) {
                    price = double.tryParse(product['price']) ?? 0;
                  } else {
                    price = product['price'] is int
                        ? product['price'].toDouble()
                        : product['price'] + 0.0; // Đảm bảo là double
                  }
                }

                // Tính giá sau khuyến mãi
                double discountPrice = 0;
                double discountPercent = 0;
                if (product['discountPercent'] != null) {
                  discountPercent = product['discountPercent'] is int
                      ? product['discountPercent'].toDouble()
                      : (product['discountPercent'] + 0.0); // Đảm bảo là double

                  if (discountPercent > 0) {
                    discountPrice = price * (1 - discountPercent / 100);
                  }
                }

                // Đảm bảo description là string
                String description = '';
                if (product['description'] != null) {
                  description = product['description'].toString();
                }

                // Tạo đối tượng sản phẩm đơn giản
                return {
                  'id': product['id'],
                  'name': product['name'] ?? 'Không có tên',
                  'price': price,
                  'discountPrice': discountPrice,
                  'discountPercent': discountPercent,
                  'category': categoryName,
                  'brand': brandName,
                  'shortDescription': description.length > 100
                      ? description.substring(0, 100) + '...'
                      : description,
                  'inStock': (product['quantity'] ?? 0) > 0,
                  'quantity': product['quantity'] ?? 0,
                  'soldCount': product['soldCount'] ?? 0,
                  'primaryImageUrl': product['primaryImageUrl'] ?? '',
                };
              }).toList();

              _productContext = jsonEncode(simplifiedProducts);
              print(
                  "Đã tải xong dữ liệu sản phẩm: ${simplifiedProducts.length} sản phẩm");

              setState(() {
                _isProductDataLoaded = true;
              });
              return; // Thoát sớm nếu đã tải thành công
            }
          }
        } catch (jsonError) {
          print("Lỗi xử lý JSON: $jsonError");
          // In ra 200 ký tự đầu tiên của response để debug
          print(
              "Response preview: ${fallbackResponse.body.substring(0, min(200, fallbackResponse.body.length))}");

          // Thử cách khác để xử lý dữ liệu
          if (fallbackResponse.body.isNotEmpty) {
            // Tạo dữ liệu mặc định nếu không thể phân tích JSON
            _productContext = '[]';
            setState(() {
              _isProductDataLoaded = false;
            });
          }
        }
      } else {
        print("Không thể tải dữ liệu sản phẩm: ${fallbackResponse.statusCode}");
      }

      // Thử sử dụng API AI
      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseApiUrl}/api/ai/product-context'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 200 && data['data'] != null) {
            _productContext = jsonEncode(data['data']);
            print(
                "Đã tải xong dữ liệu sản phẩm từ API AI: ${data['data'].length} sản phẩm");

            setState(() {
              _isProductDataLoaded = true;
            });
            return;
          }
        }
      } catch (e) {
        print("Lỗi khi tải từ API AI: $e");
      }

      // Nếu tất cả phương pháp đều thất bại, sử dụng dữ liệu mặc định
      if (!_isProductDataLoaded) {
        _productContext = '[]';
        print(
            "Không thể tải dữ liệu sản phẩm từ bất kỳ nguồn nào, sử dụng mảng trống");
      }
    } catch (e) {
      print("Lỗi tổng thể khi tải dữ liệu sản phẩm: $e");
      _productContext = '[]';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra xem câu hỏi có liên quan đến sản phẩm không
  bool _isProductQuery(String query) {
    final productIntentKeywords = [
      'sản phẩm',
      'mua',
      'giá',
      'bao nhiêu',
      'đặt hàng',
      'hàng',
      'có bán',
      'còn',
      'hết',
      'tồn kho',
      'mẫu',
      'model',
      'linh kiện',
      'card đồ họa',
      'ram',
      'cpu',
      'bàn phím',
      'chuột',
      'màn hình',
      'máy tính',
      'linh kiện',
      'ổ cứng',
      'bao nhiêu tiền',
      'khuyến mãi',
      'giảm giá',
      'mainboard',
      'bo mạch',
      'gpu',
      'intel',
      'amd',
      'radeon',
      'nvidia',
      'ssd',
      'hdd',
      'tai nghe',
      'headphone',
      'keyboard',
      'mouse'
    ];

    final lowerQuery = query.toLowerCase();
    return productIntentKeywords.any((keyword) => lowerQuery.contains(keyword));
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

    // Tìm kiếm sản phẩm trong tin nhắn nếu nó có vẻ là phản hồi về sản phẩm
    if (message.contains("sản phẩm") && message.contains("VNĐ")) {
      _processProductRecommendations(message);
    }
  }

  // Xử lý tin nhắn để tìm các đề xuất sản phẩm
  void _processProductRecommendations(String message) async {
    try {
      // Trích xuất từ khóa từ tin nhắn
      final List<String> keywords = _extractKeywords(message);

      if (keywords.isEmpty) return;

      // Tìm kiếm sản phẩm dựa trên từ khóa đầu tiên
      final keyword = keywords.first;

      // Sửa đường dẫn API, thêm '/api' vào đầu
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseApiUrl}/api/ai/search-products?keyword=$keyword&limit=3'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200 &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          // Hiển thị thông tin sản phẩm
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _showProductSuggestions(data['data']);
            }
          });
        }
      } else {
        // Fallback: Sử dụng API tìm kiếm sản phẩm trực tiếp
        final fallbackResponse = await http.get(
          Uri.parse(
              '${ApiConstants.baseApiUrl}/api/product/search?query=$keyword'),
        );

        if (fallbackResponse.statusCode == 200) {
          final fallbackData = jsonDecode(fallbackResponse.body);
          if (fallbackData['status'] == 200 &&
              fallbackData['data'] != null &&
              fallbackData['data'].isNotEmpty) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                _showProductSuggestions(fallbackData['data']);
              }
            });
          }
        }
      }
    } catch (e) {
      print("Lỗi khi xử lý đề xuất sản phẩm: $e");
    }
  }

  // Trích xuất từ khóa từ tin nhắn
  List<String> _extractKeywords(String message) {
    final productKeywords = [
      'cpu',
      'gpu',
      'ram',
      'ssd',
      'hdd',
      'mainboard',
      'card',
      'bàn phím',
      'chuột',
      'mouse',
      'keyboard',
      'màn hình',
      'tai nghe',
      'monitor',
      'intel',
      'amd',
      'nvidia',
      'asus',
      'gigabyte',
      'msi',
      'corsair',
      'cooler master',
      'hyperx',
      'logitech',
      'razer'
    ];

    final lowerMessage = message.toLowerCase();

    return productKeywords
        .where((keyword) => lowerMessage.contains(keyword))
        .toList();
  }

  // Hiển thị đề xuất sản phẩm
  void _showProductSuggestions(List<dynamic> products) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Sản phẩm gợi ý',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Product list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final discountPrice = product['discountPercent'] > 0
                        ? product['price'] *
                            (1 - product['discountPercent'] / 100)
                        : 0.0;

                    final formattedPrice = NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: '₫',
                      decimalDigits: 0,
                    ).format(product['price']);

                    final formattedDiscountPrice = discountPrice > 0
                        ? NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: '₫',
                            decimalDigits: 0,
                          ).format(discountPrice)
                        : null;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                // Sửa đường dẫn hình ảnh, thêm '/api' vào đầu
                                '${ApiConstants.baseApiUrl}/api/images/${product['primaryImageUrl']}',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (formattedDiscountPrice != null) ...[
                                    Text(
                                      formattedDiscountPrice,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      formattedPrice,
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      formattedPrice,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        product['quantity'] > 0
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: product['quantity'] > 0
                                            ? Colors.green
                                            : Colors.red,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product['quantity'] > 0
                                            ? 'Còn hàng'
                                            : 'Hết hàng',
                                        style: TextStyle(
                                          color: product['quantity'] > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Đã bán: ${product['soldCount']}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Điều hướng đến trang chi tiết sản phẩm
                                      Navigator.pop(context);
                                      _addBotMessage(
                                          'Bạn có thể xem chi tiết sản phẩm ${product['name']} trong mục "Sản phẩm" của ứng dụng.');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      minimumSize: const Size(0, 30),
                                    ),
                                    child: const Text('Xem chi tiết'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _generateAIResponse(String prompt) async {
    try {
      // Tạo nội dung yêu cầu theo định dạng của Gemini API với context sản phẩm
      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text': '''
                Thông tin sản phẩm trong cửa hàng:
                $_productContext
                
                Câu hỏi của khách hàng: $prompt

                Hãy trả lời như một nhân viên hỗ trợ cho shop online bán phụ kiện và linh kiện máy tính.
                Trả lời ngắn gọn, lịch sự và thân thiện.
                Nếu khách hỏi về sản phẩm cụ thể, vui lòng sử dụng thông tin sản phẩm từ context ở trên.
                Nếu context không có thông tin về sản phẩm cụ thể được hỏi, hãy gợi ý khách tìm kiếm trên ứng dụng.
                Gợi ý giải pháp cho các vấn đề phổ biến như vận chuyển, đổi trả, thanh toán.
                Sử dụng ngôn ngữ tiếng Việt thân thiện.
                Nếu đề cập đến giá sản phẩm, hãy sử dụng định dạng VNĐ (ví dụ: 15.990.000 VNĐ).
                KHÔNG TẠO CÁC LIÊN KẾT hoặc ĐỀ XUẤT DƯỚI DẠNG [Liên kết]. Thay vào đó, hãy chỉ đơn giản đề cập đến tên sản phẩm hoặc dịch vụ.
                Ví dụ: Thay vì "Bạn có thể tham khảo [trang CPU của cửa hàng]", hãy viết "Bạn có thể tham khảo mục CPU trong phần Sản phẩm của ứng dụng".
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

      // Kiểm tra dữ liệu sản phẩm đã được tải chưa
      if (!_isProductDataLoaded || _productContext == '[]') {
        // Cập nhật tin nhắn loading
        setState(() {
          if (loadingMessageIndex < _messages.length) {
            _messages[loadingMessageIndex] = ChatMessage(
              text: 'Đang tải dữ liệu sản phẩm...',
              isUser: false,
              timestamp: DateTime.now(),
              isLoading: true,
            );
          }
        });

        // Tải dữ liệu sản phẩm
        await _loadProductData();
      }

      // Gọi API Gemini để lấy phản hồi
      final String ai_response;

      // Sử dụng context sản phẩm nếu có, hoặc phản hồi mặc định nếu không
      if (_isProductDataLoaded && _productContext != '[]') {
        ai_response = await _generateAIResponse(message);
      } else {
        ai_response = 'Tôi không thể truy cập thông tin sản phẩm hiện tại, '
            'nhưng tôi sẽ cố gắng hỗ trợ bạn dựa trên kiến thức chung. '
            'Vui lòng hỏi câu hỏi của bạn hoặc thử lại sau.';
      }

      // Xóa tin nhắn "đang nhập..." và thêm phản hồi thực
      setState(() {
        if (loadingMessageIndex < _messages.length) {
          _messages.removeAt(loadingMessageIndex);
        }
        _addBotMessage(ai_response);
      });
    } catch (e) {
      print('Error in _sendMessage: $e');
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
        actions: [
          // Thêm nút tải lại dữ liệu sản phẩm
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProductData,
            tooltip: 'Cập nhật dữ liệu sản phẩm',
          ),
        ],
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
                      Row(
                        children: [
                          Text(
                            'Trợ lý ảo hỗ trợ 24/7',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Hiển thị trạng thái dữ liệu sản phẩm
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isProductDataLoaded
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isProductDataLoaded
                                ? 'Có dữ liệu sản phẩm'
                                : 'Chưa có dữ liệu sản phẩm',
                            style: TextStyle(
                              fontSize: 10,
                              color: _isProductDataLoaded
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
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
                  // Thêm các câu hỏi liên quan đến sản phẩm
                  _buildSuggestedQuestion(
                      'CPU Intel nào có hiệu năng tốt nhất hiện nay?'),
                  _buildSuggestedQuestion(
                      'Có bán card đồ họa NVIDIA RTX 4070 không?'),
                  _buildSuggestedQuestion(
                      'RAM nào phù hợp với máy tính chơi game?'),
                  _buildSuggestedQuestion(
                      'Có mã giảm giá nào đang áp dụng không?'),
                  _buildSuggestedQuestion('Cách theo dõi đơn hàng đã đặt?')
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
