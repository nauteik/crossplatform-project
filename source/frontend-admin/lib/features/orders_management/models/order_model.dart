import 'package:admin_interface/features/orders_management/models/order_item_model.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String paymentMethod;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    if (json['items'] != null) {
      orderItems = List<OrderItem>.from(
        (json['items'] as List).map((item) => OrderItem.fromJson(item)),
      );
    }

    // Handle date arrays from the API - [year, month, day, hour, minute, second, nanoseconds]
    DateTime parseDateArray(dynamic dateArray) {
      if (dateArray is List) {
        try {
          return DateTime(
            dateArray[0] as int, // year
            dateArray[1] as int, // month
            dateArray[2] as int, // day
            dateArray[3] as int, // hour
            dateArray[4] as int, // minute
            dateArray[5] as int, // second
          );
        } catch (e) {
          print('Error parsing date array: $e, $dateArray');
          return DateTime.now();
        }
      } else if (dateArray is String) {
        try {
          return DateTime.parse(dateArray);
        } catch (e) {
          print('Error parsing date string: $e, $dateArray');
          return DateTime.now();
        }
      } else {
        print('Unknown date format: $dateArray');
        return DateTime.now();
      }
    }

    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown Customer', // This might need to be fetched separately
      items: orderItems,
      total: json['totalAmount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      createdAt: parseDateArray(json['createdAt']),
      updatedAt: parseDateArray(json['updatedAt']),
    );
  }

  // Helper method to get a color based on order status
  static String getStatusDescription(String status) {
    switch (status) {
      case 'PENDING':
        return 'Payment Pending';
      case 'PAID':
        return 'Paid, Awaiting Shipment';
      case 'SHIPPED':
        return 'Shipped, In Transit';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      case 'FAILED':
        return 'Payment Failed';
      default:
        return 'Unknown Status';
    }
  }
}