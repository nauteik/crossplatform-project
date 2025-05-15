class ProductTypeModel {
  final String id;
  final String name;
  final String? image;

  ProductTypeModel({
    required this.id, 
    required this.name,
    this.image,
  });

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
} 