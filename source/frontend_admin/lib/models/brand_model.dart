class Brand {
  final String id;
  final String name;

  Brand({
    required this.id,
    required this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
    };
    if (id.isNotEmpty) {
      data['id'] = id;
    }
    return data;
  }
}