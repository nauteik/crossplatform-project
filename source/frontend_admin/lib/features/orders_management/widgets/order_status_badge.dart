import 'package:flutter/material.dart';
import 'package:frontend_admin/features/orders_management/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: statusInfo.color.withOpacity(0.15),
        border: Border.all(color: statusInfo.color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: 14,
            color: statusInfo.color,
          ),
          const SizedBox(width: 6),
          Text(
            Order.getStatusDescription(status),
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.w600,
              fontSize: 13.0,
            ),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo() {
    switch (status) {
      case 'PENDING':
        return StatusInfo(
          color: Colors.orange[700]!,
          icon: Icons.hourglass_empty,
        );
      case 'PAID':
        return StatusInfo(
          color: Colors.blue[600]!,
          icon: Icons.payment,
        );
      case 'SHIPPING':
        return StatusInfo(
          color: Colors.purple[600]!,
          icon: Icons.local_shipping,
        );
      case 'DELIVERED':
        return StatusInfo(
          color: Colors.green[600]!,
          icon: Icons.check_circle,
        );
      case 'CANCELLED':
        return StatusInfo(
          color: Colors.red[600]!,
          icon: Icons.cancel,
        );
      case 'FAILED':
        return StatusInfo(
          color: Colors.deepOrange[700]!,
          icon: Icons.error,
        );
      default:
        return StatusInfo(
          color: Colors.grey[600]!,
          icon: Icons.help,
        );
    }
  }
}

class StatusInfo {
  final Color color;
  final IconData icon;

  StatusInfo({required this.color, required this.icon});
}