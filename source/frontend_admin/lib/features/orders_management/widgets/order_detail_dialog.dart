import 'package:flutter/material.dart';
import 'package:frontend_admin/features/orders_management/models/order_model.dart';
import 'package:frontend_admin/features/orders_management/widgets/order_status_badge.dart';
import 'package:intl/intl.dart';
import 'package:frontend_admin/core/utils/image_helper.dart';

class OrderDetailDialog extends StatelessWidget {
  final Order order;
  
  const OrderDetailDialog({
    super.key,
    required this.order,
  });
  
  String formatCurrency(
    double amount, {
    String symbol = '₫',
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      case 'BANK_TRANSFER':
        return 'Thanh toán qua ngân hàng';
      case 'MOMO':
        return 'Thanh toán qua MoMo';
      default:
        return method;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiết Đơn hàng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                    fontSize: 24,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildInfoItem(
                                context, 
                                'Mã Đơn hàng', 
                                order.id,
                                icon: Icons.receipt_long,
                              ),
                              const SizedBox(width: 24),
                              _buildInfoItem(
                                context, 
                                'Ngày Đặt hàng', 
                                DateFormat('dd/MM/yyyy').format(order.createdAt),
                                icon: Icons.calendar_today,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                          size: 16,
                                          color: Colors.indigo[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Thông tin khách hàng:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Tên khách hàng
                                    const SizedBox(height: 2),
                                    // Username
                                    Row(
                                      children: [
                                        Text(
                                          'Username: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          order.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Email
                                    Row(
                                      children: [
                                        Text(
                                          'Email: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          order.userEmail.isNotEmpty
                                              ? order.userEmail
                                              : '${order.userName.toLowerCase().replaceAll(' ', '.')}@example.com',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Số điện thoại
                                    Row(
                                      children: [
                                        Text(
                                          'Số điện thoại: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          order.shippingAddress.phoneNumber.isNotEmpty
                                              ? order.shippingAddress.phoneNumber
                                              : 'Không có thông tin',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.local_shipping, 
                                          size: 16, 
                                          color: Colors.indigo[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Trạng thái:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    OrderStatusBadge(status: order.status),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Shipping & Payment Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shipping Address
                        Expanded(
                          child: _buildInfoBox(
                            context,
                            'Địa chỉ giao hàng',
                            order.shippingAddress.toString(),
                            Icons.location_on,
                            Colors.orange[700]!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Payment Method
                        Expanded(
                          child: _buildInfoBox(
                            context,
                            'Phương thức thanh toán',
                            _formatPaymentMethod(order.paymentMethod),
                            Icons.payment,
                            Colors.green[700]!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Order Tracking
                    _buildOrderTrackingSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Items header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sản phẩm',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                        Text(
                          '${order.items.length} sản phẩm',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Items list
                    Container(
                      height: 200, // Đặt chiều cao cố định cho danh sách sản phẩm
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: order.items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không có sản phẩm',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: order.items.length,
                              separatorBuilder: (_, __) => Divider(color: Colors.grey[200], height: 1),
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.imageUrl.isNotEmpty
                                        ? Image.network(
                                            ImageHelper.getProductImage(item.imageUrl),
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image, color: Colors.grey),
                                          ),
                                  ),
                                  title: Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Số lượng: ${item.quantity}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  trailing: Text(
                                    formatCurrency(item.price),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.indigo[700],
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                    
                    // Coupon and Total
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Coupon information (if applied)
                          if (order.couponCode != null && order.couponCode!.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.discount, size: 20, color: Colors.green[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mã giảm giá:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green[100]!),
                                  ),
                                  child: Text(
                                    order.couponCode!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Giảm:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  '- ${formatCurrency(order.couponDiscount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                          ],
                          
                          // Loyalty points information (if used)
                          if (order.loyaltyPointsUsed > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.stars, size: 20, color: Colors.amber[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Điểm thưởng sử dụng:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.amber[100]!),
                                  ),
                                  child: Text(
                                    '${order.loyaltyPointsUsed} điểm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Giảm từ điểm thưởng:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  '- ${formatCurrency(order.loyaltyPointsDiscount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.amber[700],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                          ],
                          
                          // Updated timestamp and total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cập nhật lần cuối:',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (order.couponDiscount > 0 || order.loyaltyPointsDiscount > 0) ...[
                                    Text(
                                      'Tổng tiền hàng:',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      formatCurrency(order.total),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Row(
                                    children: [
                                      Text(
                                        'Tổng thanh toán:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        formatCurrency(order.finalAmount),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.indigo[700]),
                const SizedBox(width: 8),
                Text(
                  'Lịch sử trạng thái',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
              ],
            ),
            Text(
              '${order.statusHistory.length} cập nhật',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (order.statusHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
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
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _buildStatusTimeline(),
          ),
      ],
    );
  }
  
  Widget _buildStatusTimeline() {
    final sortedHistory = order.sortedStatusHistory;
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status dot
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.status),
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Status information
              Expanded(
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
                            Order.getStatusDescription(entry.status),
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
            ],
          ),
        );
      },
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'SHIPPING':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'FAILED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildInfoItem(BuildContext context, String label, String value, {IconData? icon}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.indigo[700]),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoBox(
    BuildContext context, 
    String title, 
    String content, 
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}