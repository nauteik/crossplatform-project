class ProductModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final String primaryImageUrl;
  final List<String> imageUrls;
  final int soldCount;
  final double discountPercent;
  final Map<String, dynamic> brand;
  final Map<String, dynamic> productType;
  final Map<String, dynamic>? specifications; 
  final int? createdAt; 
  final List<dynamic> tags; 

  ProductModel({
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
    this.specifications, 
    this.createdAt, 
    this.tags = const [], 
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Xử lý brand để đảm bảo luôn là Map<String, dynamic>
    Map<String, dynamic> brandMap = {};
    if (json['brand'] != null) {
      if (json['brand'] is Map) {
        brandMap = Map<String, dynamic>.from(json['brand']);
      }
    }

    // Xử lý productType để đảm bảo luôn là Map<String, dynamic>
    Map<String, dynamic> typeMap = {};
    if (json['productType'] != null) {
      if (json['productType'] is Map) {
        try {
          typeMap = Map<String, dynamic>.from(json['productType']);
        } catch (e) {
          print('Lỗi khi xử lý productType: $e');
        }
      }
    }

    // Xử lý tags để đảm bảo luôn là List và xử lý an toàn
    List<dynamic> tagsList = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        try {
          tagsList = List<dynamic>.from(json['tags'].map((tag) {
            if (tag is Map) {
              return Map<String, dynamic>.from(tag);
            }
            return tag;
          }));
        } catch (e) {
          print('Lỗi khi xử lý tags: $e');
        }
      }
    }

    // Xử lý imageUrls để đảm bảo luôn là List<String>
    List<String> imageUrlsList = [];
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is List) {
        imageUrlsList = (json['imageUrls'] as List)
            .map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] != null) 
          ? double.tryParse(json['price'].toString()) ?? 0.0 
          : 0.0,
      quantity: (json['quantity'] != null) 
          ? int.tryParse(json['quantity'].toString()) ?? 0 
          : 0,
      description: json['description']?.toString() ?? '',
      primaryImageUrl: json['primaryImageUrl']?.toString() ?? '',
      imageUrls: imageUrlsList,
      soldCount: (json['soldCount'] != null) 
          ? int.tryParse(json['soldCount'].toString()) ?? 0 
          : 0,
      discountPercent: (json['discountPercent'] != null) 
          ? double.tryParse(json['discountPercent'].toString()) ?? 0.0 
          : 0.0,
      brand: brandMap,
      productType: typeMap,
      specifications: json['specifications'] is Map ? Map<String, dynamic>.from(json['specifications']) : null,
      createdAt: json['createdAt'] != null 
          ? int.tryParse(json['createdAt'].toString()) ?? DateTime.now().millisecondsSinceEpoch 
          : DateTime.now().millisecondsSinceEpoch,
      tags: tagsList,
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
      'createdAt': createdAt,
      'tags': tags,
    };
  }
}