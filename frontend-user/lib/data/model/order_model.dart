import 'order_item_model.dart';
import 'order_status.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final String paymentMethod;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: ((json['items'] ?? []) as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.fromString(json['status'] ?? 'PENDING'),
      paymentMethod: json['paymentMethod'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Helper method to check if order is pending
  bool get isPending => status == OrderStatus.PENDING;
  
  // Helper method to check if order is completed (paid or delivered)
  bool get isCompleted => 
      status == OrderStatus.PAID || 
      status == OrderStatus.SHIPPED || 
      status == OrderStatus.DELIVERED;
      
  // Helper method for formatting date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}