enum OrderStatus {
  PENDING,
  PAID,
  FAILED,
  SHIPPED,
  DELIVERED,
  CANCELLED;
  
  // Helper method to convert string to enum value
  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.PENDING,
    );
  }
  
  // Helper method to get display name
  String get displayName {
    switch (this) {
      case OrderStatus.PENDING:
        return 'Pending';
      case OrderStatus.PAID:
        return 'Paid';
      case OrderStatus.FAILED:
        return 'Failed';
      case OrderStatus.SHIPPED:
        return 'Shipped';
      case OrderStatus.DELIVERED:
        return 'Delivered';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
    }
  }
}