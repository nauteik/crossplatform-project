class AddressModel {
  final String? id;
  final String fullName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String district;
  final String ward;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    required this.district,
    required this.ward,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      isDefault: json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'city': city,
      'district': district,
      'ward': ward,
      'default': isDefault,
    };
  }

  String get fullAddress {
    return '$addressLine, $ward, $district, $city';
  }

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? addressLine,
    String? city,
    String? district,
    String? ward,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      isDefault: isDefault ?? this.isDefault,
    );
  }
} 