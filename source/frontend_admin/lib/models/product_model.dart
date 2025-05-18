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
  final List<dynamic> tags; // Thêm tags
  final DateTime? createdAt; // Thêm ngày tạo

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
    this.tags = const [], // Default empty list
    this.createdAt,
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
      tags: [],
      createdAt: DateTime.now(),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse createdAt if available
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      try {
        if (json['createdAt'] is String) {
          parsedCreatedAt = DateTime.parse(json['createdAt']);
        } else if (json['createdAt'] is List) {
          // Handle array format: [year, month, day, hour, minute, second]
          List<dynamic> dateArray = json['createdAt'];
          parsedCreatedAt = DateTime(
            dateArray[0] as int, // year
            dateArray[1] as int, // month
            dateArray[2] as int, // day
            dateArray.length > 3 ? dateArray[3] as int : 0, // hour
            dateArray.length > 4 ? dateArray[4] as int : 0, // minute
            dateArray.length > 5 ? dateArray[5] as int : 0, // second
          );
        }
      } catch (e) {
        print('Error parsing createdAt: $e');
      }
    }
    
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
      tags: json['tags'] != null ? List<dynamic>.from(json['tags']) : [],
      createdAt: parsedCreatedAt,
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
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
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
    List<dynamic>? tags,
    DateTime? createdAt,
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
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Helper para formatear la fecha de creación
  String get formattedCreatedAt {
    if (createdAt == null) return 'N/A';
    
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}