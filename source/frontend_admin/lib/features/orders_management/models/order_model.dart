import 'package:frontend_admin/features/orders_management/models/order_item_model.dart';

class Address {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String district;
  final String ward;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    required this.district,
    required this.ward,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  @override
  String toString() {
    return '$fullName, $addressLine, $ward, $district, $city';
  }
}

class Order {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String paymentMethod;
  final Address shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> additionalInfo;

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
    Map<String, dynamic>? additionalInfo,
  }) : this.additionalInfo = additionalInfo ?? {};

  String get userEmail => additionalInfo['userEmail'] as String? ?? '';
  String get username => additionalInfo['username'] as String? ?? userName;

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    if (json['items'] != null) {
      orderItems = List<OrderItem>.from(
        (json['items'] as List).map((item) => OrderItem.fromJson(item)),
      );
    }

    // Xử lý địa chỉ giao hàng
    Address parseAddress(dynamic addressData) {
      if (addressData is Map<String, dynamic>) {
        return Address.fromJson(addressData);
      } else {
        // Trường hợp địa chỉ là string hoặc null
        return Address(
          id: '',
          userId: '',
          fullName: '',
          phoneNumber: '',
          addressLine: addressData?.toString() ?? 'No address provided',
          city: '',
          district: '',
          ward: '',
          isDefault: false,
        );
      }
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

    // Lấy additionalInfo từ json nếu có
    Map<String, dynamic>? additionalInfo;
    if (json['additionalInfo'] != null) {
      additionalInfo = Map<String, dynamic>.from(json['additionalInfo']);
    }

    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown Customer',
      items: orderItems,
      total: json['totalAmount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? '',
      shippingAddress: parseAddress(json['shippingAddress']),
      createdAt: parseDateArray(json['createdAt']),
      updatedAt: parseDateArray(json['updatedAt']),
      additionalInfo: additionalInfo,
    );
  }

  // Helper method to get a color based on order status
  static String getStatusDescription(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'PAID':
        return 'Đã thanh toán, chờ vận chuyển';
      case 'SHIPPING':
        return 'Đang vận chuyển';
      case 'DELIVERED':
        return 'Đã giao hàng';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'FAILED':
        return 'Thanh toán thất bại';
      default:
        return 'Trạng thái không xác định';
    }
  }
}