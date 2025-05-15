import 'package:admin_interface/models/dashboard/category_sales_data.dart';
import 'package:admin_interface/models/dashboard/time_based_chart_data.dart';

class StatisticsData {
  final List<TimeBasedChartData>? timeSeriesRevenueProfitData;
  final List<TimeBasedChartData>? timeSeriesQuantityData;
  final List<CategorySalesData>? categorySalesRatio;

  StatisticsData({
    this.timeSeriesRevenueProfitData,
    this.timeSeriesQuantityData,
    this.categorySalesRatio,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
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