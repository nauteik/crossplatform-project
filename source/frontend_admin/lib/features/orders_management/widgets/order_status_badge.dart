import 'package:flutter/material.dart';
import 'package:frontend_admin/features/orders_management/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: _getStatusColor(),
      ),
      child: Text(
        Order.getStatusDescription(status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PAID':
        return Colors.blue;
      case 'SHIPPED':
        return Colors.indigo;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'FAILED':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
}