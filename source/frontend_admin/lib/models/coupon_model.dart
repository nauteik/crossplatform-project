import 'package:intl/intl.dart';

class Coupon {
  final String id;
  final String code;
  final int value;
  final int maxUses;
  final int usedCount;
  final DateTime creationTime;
  final List<String> ordersApplied;
  final bool valid;

  Coupon({
    required this.id,
    required this.code,
    required this.value,
    required this.maxUses,
    required this.usedCount,
    required this.creationTime,
    required this.ordersApplied,
    required this.valid,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final String id = json['id']?.toString() ?? '';
    final String code = json['code']?.toString() ?? '';
    final int value = json['value'] as int? ?? 0;
    final int maxUses = json['maxUses'] as int? ?? 0;
    final int usedCount = json['usedCount'] as int? ?? 0;
    final bool valid = json['valid'] as bool? ?? false;

    DateTime creationTime;
    final dynamic creationTimeJson = json['creationTime'];

    if (creationTimeJson is List && creationTimeJson.length >= 6) {
      try {
        final List<int> timeParts = List<int>.from(creationTimeJson.map((e) => e as int? ?? 0));

        final int year = timeParts[0];
        final int month = timeParts[1];
        final int day = timeParts[2];
        final int hour = timeParts[3];
        final int minute = timeParts[4];
        final int second = timeParts[5];
        final int nanoseconds = timeParts.length > 6 ? timeParts[6] : 0;
        final int microseconds = (nanoseconds / 1000).round();

        creationTime = DateTime(year, month, day, hour, minute, second, 0, microseconds);

      } catch (e) {
        print('Error parsing creationTime list: $e for data: $creationTimeJson');
        creationTime = DateTime.now();
      }
    }
     else if (creationTimeJson is String) {
         try {
            creationTime = DateTime.parse(creationTimeJson);
         } catch(e) {
             print('Error parsing creationTime string fallback: $e for data: $creationTimeJson');
             creationTime = DateTime.now();
         }
    }
    else {
      print('Warning: creationTime is missing, null or in unexpected format: $creationTimeJson');
      creationTime = DateTime.now();
    }

    final List<dynamic>? ordersAppliedListJson = json['ordersApplied'];
    List<String> ordersApplied = [];
    if (ordersAppliedListJson != null) {
       ordersApplied = ordersAppliedListJson
           .map((item) => item?.toString() ?? '')
           .where((id) => id.isNotEmpty)
           .toList();
    }

    return Coupon(
      id: id,
      code: code,
      value: value,
      maxUses: maxUses,
      usedCount: usedCount,
      creationTime: creationTime,
      ordersApplied: ordersApplied,
      valid: valid,
    );
  }

  Map<String, dynamic> toJsonForCreation() {
    return {
      'code': code,
      'value': value,
      'maxUses': maxUses,
    };
  }

  String get formattedValue {
     final formatter = NumberFormat('#,###', 'vi_VN');
     return formatter.format(value);
  }

   String get formattedCreationTime {
     final formatter = DateFormat('dd/MM/yyyy HH:mm');
     return formatter.format(creationTime);
   }
}