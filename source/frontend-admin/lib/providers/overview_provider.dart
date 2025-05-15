import 'package:admin_interface/core/utils/chart_filter_type.dart';
import 'package:admin_interface/models/dashboard/category_sales_data.dart';
import 'package:admin_interface/models/dashboard/time_based_chart_data.dart';
import 'package:admin_interface/models/overview_data.dart';
import 'package:admin_interface/repository/overview_repository.dart';
import 'package:flutter/material.dart';

class OverviewProvider with ChangeNotifier {
  final OverviewRepository _repository = OverviewRepository();

  // Các trường dữ liệu cho biểu đồ theo thời gian, sử dụng model chung
  // Backend sẽ gửi về các list riêng cho từng loại biểu đồ
  List<TimeBasedChartData>? _timeSeriesRevenueProfitData; // Dữ liệu Doanh thu/Lợi nhuận
  List<TimeBasedChartData>? get timeSeriesRevenueProfitData => _timeSeriesRevenueProfitData;

  List<TimeBasedChartData>? _timeSeriesQuantityData; // Dữ liệu Số lượng bán
  List<TimeBasedChartData>? get timeSeriesQuantityData => _timeSeriesQuantityData;

  // Giữ lại dữ liệu tỷ lệ theo danh mục (không theo thời gian)
  List<CategorySalesData>? _filteredCategorySalesRatio;
  List<CategorySalesData>? get filteredCategorySalesRatio => _filteredCategorySalesRatio;

  OverviewData? _overviewData;
  OverviewData? get overviewData => _overviewData;

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

  int? _selectedMonth;
  int? get selectedMonth => _selectedMonth;

  int? _selectedYear;
  int? get selectedYear => _selectedYear;

  OverviewProvider() {
    _currentFilterType = ChartFilterType.weekly;

    fetchData();
  }

  void setFilter({
    required ChartFilterType filterType,
    DateTime? startDate,
    DateTime? endDate,
    int? selectedMonth,
    int? selectedYear,
  }) {
    _currentFilterType = filterType;
    _startDate = startDate;
    _endDate = endDate;
    _selectedMonth = selectedMonth;
    _selectedYear = selectedYear;

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
       final data = await _repository.fetchOverviewData();

       // Chuyển đổi response thành DashboardData
       _overviewData = OverviewData.fromJson(data);
       _errorMessage = null;

    } catch (e) {
      _errorMessage = e.toString();
      _overviewData = null;
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