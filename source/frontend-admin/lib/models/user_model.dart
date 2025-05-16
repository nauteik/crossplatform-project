import 'package:intl/intl.dart';

class User {
  final String id;
  final String email;
  final String? password;
  final String? avatar;
  final String name;
  final String? username;
  final String? phone;
  final String? address;
  final String? gender;
  final DateTime? birthday;
  final String? rank;
  final int? totalSpend;
  final int role;

  User({
    required this.id,
    required this.email,
    this.password,
    this.avatar,
    required this.name,
    this.username,
    this.phone,
    this.address,
    this.gender,
    this.birthday,
    this.rank,
    this.totalSpend,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Creating User from JSON: $json');
    DateTime? parseBirthday(dynamic dateJson) {
      if (dateJson == null) return null;
      if (dateJson is String) {
        return DateTime.tryParse(dateJson);
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
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      password: null,
      avatar: json['avatar'] as String?,
      name: json['name'] ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      birthday: parseBirthday(json['birthday']),
      rank: json['rank'] as String?,
      totalSpend: parseInt(json['totalSpend']),
      role: parseRole(json['role']),
    );
    
    print('Created User: ${user.id}, ${user.name}, ${user.email}, Role: ${user.role}');
    return user;
  }

  // Phương thức chuyển User thành JSON (khi gửi lên backend)
  Map<String, dynamic> toJson() {
    String? formatBirthday(DateTime? date) {
      if (date == null) return null;
      return date.toIso8601String();
    }

    final Map<String, dynamic> data = {
      'email': email,
      'username': username,
      'password': password,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'address': address,
      'gender': gender,
      'birthday': formatBirthday(birthday),
      'rank': rank,
      'totalSpend': totalSpend,
      'role': role,
    };
    data.removeWhere((key, value) => value == null);
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
    int? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      rank: rank ?? this.rank,
      totalSpend: totalSpend ?? this.totalSpend,
      role: role ?? this.role,
    );
  }

  String get roleString {
    switch (role) {
      case 1: return 'admin';
      case 0: return 'user';
      default: return 'unknown';
    }
  }

   String get birthdayString {
     if (birthday == null) return 'N/A';
     return DateFormat('dd/MM/yyyy').format(birthday!);
   }
}