// lib/models/coupon.dart
import 'package:intl/intl.dart';
// No need for uuid if backend assigns ID

class Coupon {
  final String id;
  final String code;
  final int value;
  final int maxUses;
  final int usedCount;
  final DateTime creationTime;
  final List<String> ordersApplied;
  final bool valid; // Add the 'valid' field

  Coupon({
    required this.id,
    required this.code,
    required this.value,
    required this.maxUses,
    required this.usedCount,
    required this.creationTime,
    required this.ordersApplied,
    required this.valid, // Include in constructor
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    // --- Parsing basic types safely ---
    final String id = json['id']?.toString() ?? '';
    final String code = json['code']?.toString() ?? '';
    final int value = json['value'] as int? ?? 0;
    final int maxUses = json['maxUses'] as int? ?? 0;
    final int usedCount = json['usedCount'] as int? ?? 0;
    final bool valid = json['valid'] as bool? ?? false; // Parse 'valid' field

    // --- Parsing creationTime (List of integers) ---
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

    // --- Parsing ordersApplied (List of Strings) ---
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
      valid: valid, // Assign the parsed value
    );
  }

  // Method to convert Coupon to a backend data format for CREATION
  // Only include fields needed by the backend's @RequestBody Coupon in POST /api/coupon
  Map<String, dynamic> toJsonForCreation() {
    return {
      'code': code,
      'value': value,
      'maxUses': maxUses,
      // Do NOT send id, usedCount, creationTime, ordersApplied, valid for creation
      // Backend should set these internally
    };
  }

   // Optional: toJson for UPDATE if you have PUT/PATCH endpoint
   // Map<String, dynamic> toJsonForUpdate() {
   //    return {
   //       'id': id, // Need ID for update
   //       'code': code,
   //       'value': value,
   //       'maxUses': maxUses,
   //       'valid': valid, // Maybe allow admin to toggle valid
   //       // Do NOT send usedCount, creationTime, ordersApplied from client for update
   //    };
   // }


  String get formattedValue {
     final formatter = NumberFormat('#,###', 'vi_VN');
     return formatter.format(value);
  }

   String get formattedCreationTime {
     final formatter = DateFormat('dd/MM/yyyy HH:mm');
     return formatter.format(creationTime);
   }
}