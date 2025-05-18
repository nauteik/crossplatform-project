class Tag {
  final String id;
  final String name;
  final String color;
  final String description;
  final bool active;
  final String createdAt;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.description,
    required this.active,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '#000000',
      description: json['description']?.toString() ?? '',
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
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