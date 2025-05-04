class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final String primaryImageUrl; // Renamed from imageUrl to match backend
  final List<String> imageUrls; // Additional image URLs
  final int soldCount;
  final double discountPercent;
  final Map<String, dynamic> brand;
  final Map<String, dynamic> productType;
  final Map<String, String> specifications;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    required this.primaryImageUrl,
    required this.imageUrls,
    required this.soldCount,
    required this.discountPercent,
    required this.brand,
    required this.productType,
    required this.specifications,
  });

  // Constructor for creating a new product with default values
  factory Product.create() {
    return Product(
      id: '',
      name: '',
      price: 0.0,
      quantity: 0,
      description: '',
      primaryImageUrl: '',
      imageUrls: [],
      soldCount: 0,
      discountPercent: 0,
      brand: {},
      productType: {},
      specifications: {},
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      primaryImageUrl: json['primaryImageUrl'] ?? '',
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls'])
          : [],
      soldCount: json['soldCount'] ?? 0,
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      brand: json['brand'] ?? {},
      productType: json['productType'] ?? {},
      specifications: json['specifications'] != null 
          ? Map<String, String>.from(json['specifications'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'primaryImageUrl': primaryImageUrl,
      'imageUrls': imageUrls,
      'soldCount': soldCount,
      'discountPercent': discountPercent,
      'brand': brand,
      'productType': productType,
      'specifications': specifications,
    };
  }

  // Create a copy with modified fields
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? description,
    String? primaryImageUrl,
    List<String>? imageUrls,
    int? soldCount,
    double? discountPercent,
    Map<String, dynamic>? brand,
    Map<String, dynamic>? productType,
    Map<String, String>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      soldCount: soldCount ?? this.soldCount,
      discountPercent: discountPercent ?? this.discountPercent,
      brand: brand ?? this.brand,
      productType: productType ?? this.productType,
      specifications: specifications ?? this.specifications,
    );
  }
}