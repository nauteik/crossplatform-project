class CategorySalesData {
  final String categoryName;
  final int totalQuantitySold;

  CategorySalesData({
    required this.categoryName,
    required this.totalQuantitySold,
  });

  factory CategorySalesData.fromJson(Map<String, dynamic> json) {
    return CategorySalesData(
      categoryName: json['categoryName'] ?? 'Unknown Category',
      totalQuantitySold: json['totalQuantitySold'] ?? 0,
    );
  }
}