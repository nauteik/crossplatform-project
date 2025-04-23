import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/model/order_model.dart';
import '../../../data/model/order_status.dart';
import '../payment_feature.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        // Prevent going back to checkout
        automaticallyImplyLeading: false,
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
                    child: const Text('View Order History', style: TextStyle(fontSize: 16)),
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
                    child: const Text('Continue Shopping', style: TextStyle(fontSize: 16)),
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
            'Thank you for your order!',
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
            'Order #${order.id.substring(0, 8)}',
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
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order date
            _buildDetailRow('Order Date', formattedDate),
            
            const Divider(),
            
            // Payment method
            _buildDetailRow(
              'Payment Method', 
              _formatPaymentMethod(order.paymentMethod),
            ),
            
            const Divider(),
            
            // Order status
            _buildDetailRow(
              'Order Status',
              order.status.displayName,
              valueColor: _getStatusColor(order.status),
            ),
            
            const Divider(),
            
            // Shipping address
            _buildDetailRow('Shipping Address', order.shippingAddress, isMultiLine: true),
            
            const Divider(),
            
            // Total amount
            _buildDetailRow(
              'Total Amount',
              '\$${order.totalAmount.toStringAsFixed(2)}',
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
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
              'Order Items',
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
                        '${ApiConstants.baseApiUrl}${item.imageUrl}',
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
                            'Quantity: ${item.quantity}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: \$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Item total
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
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
        return 'Credit Card';
      case 'COD':
        return 'Cash on Delivery';
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