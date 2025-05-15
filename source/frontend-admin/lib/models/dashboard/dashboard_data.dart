import 'package:admin_interface/models/dashboard/category_sales_data.dart';
import 'package:admin_interface/models/dashboard/time_based_chart_data.dart';

class DashboardData {
  final int totalUsers;
  final int totalOrders;
  final int totalProductTypes;
  final int totalProducts;
  final List<TimeBasedChartData>? timeSeriesRevenueProfitData;
  final List<TimeBasedChartData>? timeSeriesQuantityData;
  final List<CategorySalesData>? categorySalesRatio;

  DashboardData({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProductTypes,
    required this.totalProducts,
    this.timeSeriesRevenueProfitData,
    this.timeSeriesQuantityData,
    this.categorySalesRatio,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalUsers: json['totalUsers'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalProductTypes: json['totalProductTypes'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
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