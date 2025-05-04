import 'package:flutter/material.dart';
import 'package:admin_interface/features/orders_management/models/order_model.dart';
import 'package:admin_interface/features/orders_management/widgets/order_status_badge.dart';
import 'package:intl/intl.dart';

class OrderDetailDialog extends StatelessWidget {
  final Order order;
  
  const OrderDetailDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            
            // Order ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(order.id)
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Order Date:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat('MMM dd, yyyy').format(order.createdAt)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Customer and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(order.userName),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Shipping Address
            Text(
              'Shipping Address:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(order.shippingAddress),
            const SizedBox(height: 16),
            
            // Payment Method
            Text(
              'Payment Method:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(order.paymentMethod),
            const SizedBox(height: 16),
            
            // Items
            Text(
              'Items:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            Flexible(
              child: order.items.isEmpty
                  ? const Text('No items found')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: item.imageUrl.isNotEmpty
                              ? Image.network(
                                  item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                          title: Text(item.productName),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
            const Divider(),
            
            // Total
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            
            // Last Updated
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(order.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}