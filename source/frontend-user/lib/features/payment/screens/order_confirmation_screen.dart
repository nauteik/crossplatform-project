import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/model/order_model.dart';
import '../../../data/model/order_status.dart';
import '../../../data/model/status_history_entry_model.dart';
import '../payment_feature.dart';
import 'package:frontend_user/core/utils/image_helper.dart';
import 'package:frontend_user/core/utils/format_currency.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đơn hàng'),
        // Cho phép pop về màn hình chính
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => _continueShopping(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success message
            _buildConfirmationHeader(),
            
            const SizedBox(height: 24),
            
            // Order details card
            _buildOrderDetailsCard(),
            
            const SizedBox(height: 24),
            
            // Order tracking
            _buildOrderTrackingCard(),
            
            const SizedBox(height: 24),
            
            // Items list
            _buildOrderItemsList(),
            
            const SizedBox(height: 32),
            
            // Order history and Continue shopping buttons
            Row(
              children: [
                // View order history button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () => _viewOrderHistory(context),
                    child: const Text('Xem lịch sử đơn hàng', style: TextStyle(fontSize: 16)),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Continue shopping button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _continueShopping(context),
                    child: const Text('Tiếp tục mua hàng', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationHeader() {
    return Column(
      children: [
        // Success icon
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green,
        ),
        
        const SizedBox(height: 16),
        
        // Thank you text
        const Center(
          child: Text(
            'Cảm ơn bạn đã đặt hàng!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Order number
        Center(
          child: Text(
            'Order #${order.id}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsCard() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(order.createdAt);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết đơn hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order date
            _buildDetailRow('Ngày đặt hàng', formattedDate),
            
            const Divider(),
            
            // Payment method
            _buildDetailRow(
              'Phương thức thanh toán', 
              _formatPaymentMethod(order.paymentMethod),
            ),
            
            const Divider(),
            
            // Order status
            _buildDetailRow(
              'Trạng thái đơn hàng',
              order.status == OrderStatus.PENDING ? 'Chờ xử lý' :
              order.status == OrderStatus.PAID ? 'Đã thanh toán' :
              order.status == OrderStatus.FAILED ? 'Thất bại' :
              order.status == OrderStatus.SHIPPED ? 'Đang giao hàng' :
              order.status == OrderStatus.DELIVERED ? 'Đã giao hàng' :
              'Đã hủy',
              valueColor: _getStatusColor(order.status),
            ),
            
            const Divider(),
            
            // Shipping address
            _buildDetailRow('Địa chỉ giao hàng', order.formattedAddress, isMultiLine: true),
            
            const Divider(),
            
            // Display coupon information if available
            if (order.hasCoupon) ...[
              _buildDetailRow(
                'Mã giảm giá',
                order.couponCode ?? '',
                valueColor: Colors.green,
              ),
              
              const Divider(),
              
              _buildDetailRow(
                'Giảm giá',
                formatCurrency(order.couponDiscount),
                valueColor: Colors.green,
              ),
              
              const Divider(),
            ],
            
            // Display loyalty points information if used
            if (order.hasLoyaltyPoints) ...[
              _buildDetailRow(
                'Điểm thưởng sử dụng',
                '${order.loyaltyPointsUsed} điểm',
                valueColor: Colors.amber[700],
              ),
              
              const Divider(),
              
              _buildDetailRow(
                'Giảm giá từ điểm thưởng',
                formatCurrency(order.loyaltyPointsDiscount),
                valueColor: Colors.amber[700],
              ),
              
              const Divider(),
            ],
            
            // Subtotal amount (if coupon is applied)
            if (order.hasCoupon || order.hasLoyaltyPoints) 
              _buildDetailRow(
                'Tổng tiền hàng',
                formatCurrency(order.totalAmount),
              ),
              
            // Final amount
            _buildDetailRow(
              order.hasCoupon ? 'Tổng tiền thanh toán' : 'Tổng số tiền',
              formatCurrency(order.hasCoupon ? order.finalAmount : order.totalAmount),
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTrackingCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Theo dõi đơn hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.sortedStatusHistory.length} cập nhật',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (order.statusHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Chưa có thông tin cập nhật trạng thái',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              _buildStatusTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final sortedHistory = order.sortedStatusHistory;
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        final isLast = index == sortedHistory.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getStatusColor(entry.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Status information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.message,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(entry.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(entry.status).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            entry.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(entry.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDateTime(entry.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  Widget _buildOrderItemsList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm đơn hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...order.items.map((item) => Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        ImageHelper.getImage(item.imageUrl),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Số lượng: ${item.quantity}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Giá: ${formatCurrency(item.price)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Item total
                    Text(
                      formatCurrency(item.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                if (order.items.last != item) const Divider(height: 24),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label, 
    String value, {
    bool isMultiLine = false,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ?? TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PAID:
        return Colors.green;
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.FAILED:
        return Colors.red;
      case OrderStatus.CANCELLED:
        return Colors.red;
      case OrderStatus.SHIPPED:
        return Colors.blue;
      case OrderStatus.DELIVERED:
        return Colors.green;
    }
  }

  void _continueShopping(BuildContext context) {
    // Navigate to home screen and clear back stack
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _viewOrderHistory(BuildContext context) {
    // Navigate to order history screen using PaymentFeature
    PaymentFeature.navigateToOrderHistory(
      context: context,
      userId: order.userId,
    );
  }
}