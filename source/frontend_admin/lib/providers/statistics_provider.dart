import 'package:flutter/material.dart';
import 'package:frontend_admin/core/utils/chart_filter_type.dart';
import 'package:frontend_admin/models/category_sales_data.dart';
import 'package:frontend_admin/models/statistics_model.dart';
import 'package:frontend_admin/models/time_based_chart_data.dart';
import 'package:frontend_admin/repository/statistics_repository.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsRepository _repository = StatisticsRepository();

  List<TimeBasedChartData>? _timeSeriesRevenueProfitData;
  List<TimeBasedChartData>? get timeSeriesRevenueProfitData => _timeSeriesRevenueProfitData;

  List<TimeBasedChartData>? _timeSeriesQuantityData;
  List<TimeBasedChartData>? get timeSeriesQuantityData => _timeSeriesQuantityData;

  List<CategorySalesData>? _filteredCategorySalesRatio;
  List<CategorySalesData>? get filteredCategorySalesRatio => _filteredCategorySalesRatio;

  StatisticsData? _statisticsData;
  StatisticsData? get statisticsData => _statisticsData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ChartFilterType _currentFilterType = ChartFilterType.weekly;
  ChartFilterType get currentFilterType => _currentFilterType;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  int? _selectedMonth = DateTime.now().month;
  int? get selectedMonth => _selectedMonth;

  int? _selectedQuarter;
  int? get selectedQuarter => _selectedQuarter;

  int? _selectedYear = DateTime.now().year;
  int? get selectedYear => _selectedYear;

  StatisticsProvider() {
    _currentFilterType = ChartFilterType.weekly;

    fetchData();
  }

  void setFilter({
    required ChartFilterType filterType,
    DateTime? startDate,
    DateTime? endDate,
    int? selectedMonth,
    int? selectedYear,
    int? selectedQuarter,  // Add this parameter
  }) {
    _currentFilterType = filterType;
    _startDate = startDate;
    _endDate = endDate;
    _selectedMonth = selectedMonth;
    _selectedYear = selectedYear;
    _selectedQuarter = selectedQuarter;  // Set the quarter

    // Reset dữ liệu cũ
    _timeSeriesRevenueProfitData = null;
    _timeSeriesQuantityData = null;
    _filteredCategorySalesRatio = null;
    _errorMessage = null; // Reset lỗi

    notifyListeners(); // Thông báo UI rằng bộ lọc đã thay đổi

    // Fetch dữ liệu mới với bộ lọc mới
    fetchData();
  }


  Future<void> fetchData() async {
    _isLoading = true;

    try {
       final filterParams = {
          'filterType': _currentFilterType.toString().split('.').last, // Gửi tên enum dạng String
          if (_startDate != null) 'startDate': _startDate!.toIso8601String().split('T').first, // YYYY-MM-DD
          if (_endDate != null) 'endDate': _endDate!.toIso8601String().split('T').first, // YYYY-MM-DD
          if (_selectedMonth != null) 'month': _selectedMonth.toString(),
          if (_selectedQuarter != null) 'quarter': _selectedQuarter.toString(),
          if (_selectedYear != null) 'year': _selectedYear.toString(),
       };
       // Gọi repository với tham số lọc
       final data = await _repository.fetchFilteredDashboardData(filterParams);

       // Chuyển đổi response thành DashboardData
       _statisticsData = StatisticsData.fromJson(data);
       _errorMessage = null;

    } catch (e) {
      _errorMessage = e.toString();
      _statisticsData = null;
    } finally {
      _isLoading = false;
      notifyListeners(); // Thông báo kết thúc loading và dữ liệu đã cập nhật
    }
  }

   Future<void> refreshData() async {
     if (!_isLoading) {
        await fetchData();
     }
   }
}