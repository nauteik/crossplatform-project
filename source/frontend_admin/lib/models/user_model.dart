import 'package:intl/intl.dart';

class User {
  final String id;
  final String email;
  final String? password;
  final String? avatar;
  final String name;
  final String? username;
  final String? phone;
  final String? gender;
  final DateTime? birthday;
  final String? rank;
  final int? totalSpend;
  final int? loyaltyPoints;
  final int role; 
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    this.password,
    this.avatar,
    required this.name,
    this.username,
    this.phone,
    this.gender,
    this.birthday,
    this.rank,
    this.totalSpend,
    this.loyaltyPoints,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? parseNullableString(dynamic value) {
      if (value == null) return null;
      if (value is String && value.trim().toLowerCase() == "chưa cập nhật") return null;
      if (value is String && value.isNotEmpty) return value;
      return null;
    }

    String parseId(dynamic idJson) {
      if (idJson is String) return idJson;
      if (idJson is Map && idJson.containsKey('\$oid')) {
        return idJson['\$oid'] as String;
      }
      return '';
    }

    DateTime? parseDateTime(dynamic dateJson) {
      if (dateJson == null) return null;
      if (dateJson is String) {
        return DateTime.tryParse(dateJson);
      }
      if (dateJson is Map && dateJson.containsKey('\$date')) {
         final dateValue = dateJson['\$date'];
         if (dateValue is String) {
             return DateTime.tryParse(dateValue);
         }
      }
      return null;
    }

     int? parseInt(dynamic value) {
       if (value == null) return null;
       if (value is int) return value;
       if (value is num) return value.toInt();
       if (value is String) return int.tryParse(value);
       return null;
     }

      int parseRole(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

    var user = User(
      id: parseId(json['_id'] ?? json['id']),
      email: json['email'] ?? '',
      password: null,
      avatar: parseNullableString(json['avatar']),
      name: json['name'] ?? '',
      username: parseNullableString(json['username']),
      phone: parseNullableString(json['phone']),
      gender: parseNullableString(json['gender']),
      birthday: parseDateTime(json['birthday']),
      rank: parseNullableString(json['rank']),
      totalSpend: parseInt(json['totalSpend']),
      loyaltyPoints: parseInt(json['loyaltyPoints']),
      role: parseRole(json['role']),
      createdAt: parseDateTime(json['createdAt']), 
    );
    return user;
  }

  Map<String, dynamic> toJson() {
    String? formatBirthdayForJson(DateTime? date) {
      if (date == null) return null;
      return date.toIso8601String();
    }

    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
      'avatar': avatar,
      'username': username,
      'phone': phone,
      'gender': gender,
      'birthday': formatBirthdayForJson(birthday),
      'role': role,
    };
    return data;
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? avatar,
    String? name,
    String? username,
    String? phone,
    String? address,
    String? gender,
    DateTime? birthday,
    String? rank,
    int? totalSpend,
    int? loyaltyPoints,
    int? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      rank: rank ?? this.rank,
      totalSpend: totalSpend ?? this.totalSpend,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get roleString {
    switch (role) {
      case 1: return 'Admin';
      case 0: return 'User';
      default: return 'Không xác định';
    }
  }

   String get birthdayString {
     if (birthday == null) return 'Chưa cập nhật';
     return DateFormat('dd/MM/yyyy').format(birthday!);
   }

    String get createdAtString {
     if (createdAt == null) return 'Chưa cập nhật';
     return DateFormat('dd/MM/yyyy HH:mm').format(createdAt!);
   }
}