import 'package:frontend_admin/models/category_sales_data.dart';
import 'package:frontend_admin/models/time_based_chart_data.dart' show TimeBasedChartData;

class OverviewData {
  final int totalUsers;
  final int totalOrders;
  final int totalProductTypes;
  final int totalProducts;
  final int newUsers;
  final int newOrders;
  final double totalRevenue;
  final double totalProfit;
  final List<TimeBasedChartData>? timeSeriesRevenueProfitData;
  final List<TimeBasedChartData>? timeSeriesQuantityData;
  final List<CategorySalesData>? categorySalesRatio;

  OverviewData({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProductTypes,
    required this.totalProducts,
    required this.newUsers,
    required this.newOrders,
    required this.totalRevenue,
    required this.totalProfit,
    this.timeSeriesRevenueProfitData,
    this.timeSeriesQuantityData,
    this.categorySalesRatio,
  });

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    return OverviewData(
      totalUsers: json['totalUsers'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalProductTypes: json['totalProductTypes'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
      newOrders: json['newOrders'] ?? 0,
      totalRevenue: json['totalRevenue'] ?? 0,
      totalProfit: json['totalProfit'] ?? 0,
      timeSeriesRevenueProfitData: (json['timeSeriesRevenueProfitData'] as List<dynamic>?)
          ?.map((e) => TimeBasedChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeSeriesQuantityData: (json['timeSeriesQuantityData'] as List<dynamic>?)
          ?.map((e) => TimeBasedChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      categorySalesRatio: (json['categorySalesRatio'] as List<dynamic>?)
          ?.map((e) => CategorySalesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}