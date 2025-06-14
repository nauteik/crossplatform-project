import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/model/order_model.dart';
import '../../../data/model/order_status.dart';
import '../providers/payment_provider.dart';
import 'order_confirmation_screen.dart';
import 'package:frontend_user/core/utils/format_currency.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;

  const OrderHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with WidgetsBindingObserver {
  late Future<List<OrderModel>> _ordersFuture;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOrders();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      _loadOrders();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when screen becomes visible
    _loadOrders();
  }
  
  void _loadOrders() {
    setState(() {
      _ordersFuture = context.read<PaymentProvider>().getOrderHistory(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadOrders();
          });
        },
        child: FutureBuilder<List<OrderModel>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadOrders();
                        });
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không có đơn hàng nào',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lịch sử đơn hàng của bạn sẽ xuất hiện ở đây',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate back to home/product browsing
                        Navigator.of(context).pop();
                      },
                      child: const Text('Bắt đầu mua hàng'),
                    ),
                  ],
                ),
              );
            }
            
            // Sort orders by date (newest first)
            final orders = snapshot.data!;
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(order.createdAt);
    
    // Get total items count
    final totalItems = order.items.fold<int>(
      0, (sum, item) => sum + item.quantity
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Status and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(order.status),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(order.hasCoupon || order.hasLoyaltyPoints ? order.finalAmount : order.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (order.couponDiscount != null && order.couponDiscount! > 0)
                        Text(
                          'Giảm: -${formatCurrency(order.couponDiscount! + order.loyaltyPointsDiscount!)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Items summary
              Text(
                '$totalItems ${totalItems == 1 ? 'sản phẩm' : 'sản phẩm'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              
              const SizedBox(height: 8),
              
              // Payment method
              Text(
                'Phương thức thanh toán: ${_formatPaymentMethod(order.paymentMethod)}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              
              // Coupon info
              if (order.couponCode != null && order.couponCode!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.discount_outlined, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Mã giảm giá: ${order.couponCode}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
              
              // Loyalty points info
              if (order.loyaltyPointsUsed > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'Điểm thưởng: -${formatCurrency(order.loyaltyPointsDiscount)}',
                        style: TextStyle(color: Colors.amber[800]),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // View details button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderConfirmationScreen(order: order),
                        ),
                      );
                    },
                    child: const Text('Xem chi tiết'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor = Colors.white;
    
    switch (status) {
      case OrderStatus.PAID:
        bgColor = Colors.green;
        break;
      case OrderStatus.PENDING:
        bgColor = Colors.orange;
        break;
      case OrderStatus.FAILED:
        bgColor = Colors.red;
        break;
      case OrderStatus.CANCELLED:
        bgColor = Colors.red[300]!;
        break;
      case OrderStatus.SHIPPED:
        bgColor = Colors.blue;
        break;
      case OrderStatus.DELIVERED:
        bgColor = Colors.green[700]!;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status == OrderStatus.PENDING ? 'Chờ xử lý' :
        status == OrderStatus.PAID ? 'Đã thanh toán' :
        status == OrderStatus.FAILED ? 'Thất bại' :
        status == OrderStatus.SHIPPED ? 'Đang giao hàng' :
        status == OrderStatus.DELIVERED ? 'Đã giao hàng' :
        'Đã hủy',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      case "MOMO":
        return 'Thanh toán qua MoMo';
      case "BANK_TRANSFER":
        return 'Thanh toán qua ngân hàng';
      default:
        return method;
    }
  }
}