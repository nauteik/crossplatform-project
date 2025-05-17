class Tag {
  final String id;
  final String name;
  final String color;
  final String description;
  final bool active;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    this.description = '',
    this.active = true,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
      description: json['description'] ?? '',
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'active': active,
    };
  }
} 