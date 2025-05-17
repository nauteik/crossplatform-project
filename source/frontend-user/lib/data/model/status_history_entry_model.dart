import 'order_status.dart';

class StatusHistoryEntryModel {
  final OrderStatus status;
  final DateTime timestamp;
  final String message;

  StatusHistoryEntryModel({
    required this.status,
    required this.timestamp,
    required this.message,
  });

  factory StatusHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntryModel(
      status: OrderStatus.fromString(json['status'] ?? 'PENDING'),
      timestamp: _parseDateTime(json['timestamp']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
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
} 