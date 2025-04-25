class CartItemModel {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['productId'] ?? '',
      name: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': id,
      'productName': name,  // Changed 'name' to 'productName' to match backend expectation
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}