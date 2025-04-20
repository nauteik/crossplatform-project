class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final String imageUrl;
  final int soldCount;
  final double discountPercent;
  final Map<String, dynamic> brand;
  final Map<String, dynamic> productType;

  Product ({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    required this.imageUrl,
    required this.soldCount,
    required this.discountPercent,
    required this.brand,
    required this.productType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      soldCount: json['soldCount'] ?? 0,
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      brand: json['brand'] ?? {},
      productType: json['productType'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'imageUrl': imageUrl,
      'soldCount': soldCount,
      'discountPercent': discountPercent,
      'brand': brand,
      'productType': productType,
    };
  }
} 