class StatusHistoryEntry {
  final String status;
  final DateTime timestamp;
  final String message;

  StatusHistoryEntry({
    required this.status,
    required this.timestamp,
    required this.message,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    // Handle date arrays from the API - [year, month, day, hour, minute, second, nanoseconds]
    DateTime parseDateTime(dynamic value) {
      if (value is List) {
        try {
          return DateTime(
            value[0] as int, // year
            value[1] as int, // month
            value[2] as int, // day
            value[3] as int, // hour
            value[4] as int, // minute
            value[5] as int, // second
          );
        } catch (e) {
          print('Error parsing date array: $e, $value');
          return DateTime.now();
        }
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing date string: $e, $value');
          return DateTime.now();
        }
      } else {
        print('Unknown date format: $value');
        return DateTime.now();
      }
    }

    return StatusHistoryEntry(
      status: json['status'] ?? 'UNKNOWN',
      timestamp: parseDateTime(json['timestamp']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }
} 