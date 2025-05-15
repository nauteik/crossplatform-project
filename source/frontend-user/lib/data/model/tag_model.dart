class TagModel {
  final String id;
  final String name;
  final String? color;
  final String? description;
  final bool active;
  final int? createdAt;

  TagModel({
    required this.id,
    required this.name,
    this.color,
    this.description,
    this.active = true,
    this.createdAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'],
      description: json['description'],
      active: json['active'] ?? true,
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'active': active,
      'createdAt': createdAt,
    };
  }
} 