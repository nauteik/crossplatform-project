import 'order_item_model.dart';
import 'order_status.dart';
import 'status_history_entry_model.dart';
import '../../core/models/address_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String? couponCode;
  final double couponDiscount;
  final int loyaltyPointsUsed;
  final double loyaltyPointsDiscount;
  final OrderStatus status;
  final String paymentMethod;
  final AddressModel shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusHistoryEntryModel> statusHistory;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.couponCode,
    this.couponDiscount = 0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsDiscount = 0,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
    this.statusHistory = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is List && value.length >= 6) {
        // [year, month, day, hour, minute, second, ...]
        return DateTime(
          value[0], value[1], value[2], value[3], value[4], value[5]
        );
      } else {
        return DateTime.now();
      }
    }
    
    // Xử lý shippingAddress có thể là chuỗi (legacy) hoặc object
    AddressModel parseAddress(dynamic addressData) {
      if (addressData is String) {
        // Nếu là chuỗi (format cũ), tạo AddressModel với fullAddress
        return AddressModel(
          fullName: '',
          phoneNumber: '',
          addressLine: addressData,
          city: '',
          district: '',
          ward: '',
        );
      } else if (addressData is Map<String, dynamic>) {
        // Nếu là object, parse thành AddressModel
        return AddressModel.fromJson(addressData);
      } else {
        // Fallback nếu không có thông tin địa chỉ
        return AddressModel(
          fullName: '',
          phoneNumber: '',
          addressLine: '',
          city: '',
          district: '',
          ward: '',
        );
      }
    }
    
    // Parse status history
    List<StatusHistoryEntryModel> parseStatusHistory(dynamic statusHistoryData) {
      if (statusHistoryData == null) {
        return [];
      }
      
      try {
        return (statusHistoryData as List)
            .map((entry) => StatusHistoryEntryModel.fromJson(entry))
            .toList();
      } catch (e) {
        print('Error parsing status history: $e');
        return [];
      }
    }
    
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: ((json['items'] ?? []) as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      couponCode: json['couponCode'],
      couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
      loyaltyPointsUsed: json['loyaltyPointsUsed'] ?? 0,
      loyaltyPointsDiscount: (json['loyaltyPointsDiscount'] ?? 0).toDouble(),
      status: OrderStatus.fromString(json['status'] ?? 'PENDING'),
      paymentMethod: json['paymentMethod'] ?? '',
      shippingAddress: parseAddress(json['shippingAddress']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      statusHistory: parseStatusHistory(json['statusHistory']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'loyaltyPointsDiscount': loyaltyPointsDiscount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'statusHistory': statusHistory.map((entry) => entry.toJson()).toList(),
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
  
  // Helper method to get formatted address
  String get formattedAddress {
    return shippingAddress.fullAddress;
  }
  
  // Helper method to get final amount after all discounts
  double get finalAmount {
    return totalAmount - couponDiscount - loyaltyPointsDiscount;
  }
  
  // Helper method to check if coupon was applied
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;
  
  // Helper method to check if loyalty points were used
  bool get hasLoyaltyPoints => loyaltyPointsUsed > 0;
  
  // Helper method to get total discount amount
  double get totalDiscount => couponDiscount + loyaltyPointsDiscount;
  
  // Helper method to calculate loyalty points earned (10% of final amount)
  int get loyaltyPointsEarned => (finalAmount * 0.1).round();
  
  // Helper method to get sorted status history (newest first)
  List<StatusHistoryEntryModel> get sortedStatusHistory {
    final sorted = List<StatusHistoryEntryModel>.from(statusHistory);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }
}