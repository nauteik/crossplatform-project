// lib/providers/mock_dashboard_provider.dart
// File này chứa cả logic tạo dữ liệu giả và Mock Provider cho Dashboard

import 'package:admin_interface/core/utils/chart_filter_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:intl/intl.dart'; // Import để định dạng ngày tháng
import 'dart:math'; // Import để tạo số ngẫu nhiên

// Import các model cần thiết
// Đảm bảo các file model này tồn tại và có cấu trúc đúng như đã định nghĩa trước đó
import 'package:admin_interface/models/dashboard/dashboard_data.dart';
import 'package:admin_interface/models/dashboard/time_based_chart_data.dart';
import 'package:admin_interface/models/dashboard/category_sales_data.dart';


// --- Logic Tạo Dữ liệu Giả ---

// Hàm tạo dữ liệu DashboardData giả dựa trên bộ lọc
DashboardData _createMockDashboardDataWithFilter({
  required ChartFilterType filterType,
  DateTime? startDate,
  DateTime? endDate,
  int? selectedMonth,
  int? selectedYear,
}) {
   final random = Random();
   // Giữ nguyên các chỉ số tổng (thường là toàn thời gian trong Simple Dashboard)
   final fakeTotalUsers = 15000 + random.nextInt(2000); // Số ngẫu nhiên khoảng 15000-17000
   final fakeTotalOrders = 8000 + random.nextInt(1500);  // Số ngẫu nhiên khoảng 8000-9500
   final fakeTotalProductTypes = 20 + random.nextInt(5);  // Số ngẫu nhiên khoảng 20-25
   final fakeTotalProducts = 700 + random.nextInt(100);   // Số ngẫu nhiên khoảng 700-800

   // Các list dữ liệu biểu đồ sẽ được tạo dựa trên bộ lọc
   List<TimeBasedChartData> timeSeriesRevenueProfitData = [];
   List<TimeBasedChartData> timeSeriesQuantityData = [];
   List<CategorySalesData> categorySalesRatio = []; // Dữ liệu tỷ lệ danh mục giả

   final now = DateTime.now();

   // --- Logic tạo dữ liệu giả dựa vào filterType và tham số ---
   switch (filterType) {
     case ChartFilterType.weekly:
       // Tạo dữ liệu giả cho 7 ngày gần nhất
       for (int i = 6; i >= 0; i--) {
         final date = now.subtract(Duration(days: i));
         final dateString = DateFormat('yyyy-MM-dd').format(date); // Format YYYY-MM-DD

         final revenue = 5000000.0 + random.nextDouble() * 5000000.0; // Biến động hàng ngày
         final profit = revenue * (0.15 + random.nextDouble() * 0.05) ; // 15-20%
         final quantity = 50 + random.nextInt(30);

         timeSeriesRevenueProfitData.add(TimeBasedChartData(timePeriod: dateString, revenue: revenue, profit: profit));
         timeSeriesQuantityData.add(TimeBasedChartData(timePeriod: dateString, quantitySold: quantity));
       }
       // Dữ liệu tỷ lệ danh mục giả cho tuần (có thể đơn giản hơn)
        categorySalesRatio = [
           CategorySalesData(categoryName: 'Laptops', totalQuantitySold: 100 + random.nextInt(30)),
           CategorySalesData(categoryName: 'Monitors', totalQuantitySold: 80 + random.nextInt(20)),
           CategorySalesData(categoryName: 'Keyboards & Mice', totalQuantitySold: 120 + random.nextInt(40)),
        ];
       break;

     case ChartFilterType.dateRange:
       // Tạo dữ liệu giả theo ngày trong khoảng startDate - endDate
       if (startDate != null && endDate != null) {
         final daysCount = endDate.difference(startDate).inDays;
         // Giới hạn số ngày để tránh tạo quá nhiều dữ liệu giả
         final limitedDays = daysCount > 365 ? 365 : daysCount; // Ví dụ: giới hạn 1 năm
         for (int i = 0; i <= limitedDays; i++) {
            final date = startDate.add(Duration(days: i));
            final dateString = DateFormat('yyyy-MM-dd').format(date);

            final revenue = 2000000.0 + random.nextDouble() * 3000000.0;
            final profit = revenue * (0.15 + random.nextDouble() * 0.05);
            final quantity = 20 + random.nextInt(20);

            timeSeriesRevenueProfitData.add(TimeBasedChartData(timePeriod: dateString, revenue: revenue, profit: profit));
            timeSeriesQuantityData.add(TimeBasedChartData(timePeriod: dateString, quantitySold: quantity));
         }
       }
        // Dữ liệu tỷ lệ danh mục giả cho khoảng ngày (sử dụng dữ liệu chung lớn hơn)
        categorySalesRatio = _createMockAllTimeCategorySalesRatio();
       break;

     case ChartFilterType.monthly:
       // Tạo dữ liệu giả theo ngày cho tháng/năm cụ thể
       if (selectedMonth != null && selectedYear != null) {
         final yearMonth = DateTime(selectedYear, selectedMonth);
         // Đảm bảo ngày tháng hợp lệ
         if (yearMonth.year == selectedYear && yearMonth.month == selectedMonth) {
            final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day; // Ngày cuối tháng

            for (int i = 1; i <= daysInMonth; i++) {
              final date = DateTime(selectedYear, selectedMonth, i);
              final dateString = DateFormat('yyyy-MM-dd').format(date);

              // Tạo dữ liệu giả hàng ngày cho tháng đó
              final revenue = 2000000.0 + random.nextDouble() * 3000000.0;
              final profit = revenue * (0.15 + random.nextDouble() * 0.05);
              final quantity = 20 + random.nextInt(20);

              timeSeriesRevenueProfitData.add(TimeBasedChartData(timePeriod: dateString, revenue: revenue, profit: profit));
              timeSeriesQuantityData.add(TimeBasedChartData(timePeriod: dateString, quantitySold: quantity));
            }
         }
       }
        categorySalesRatio = _createMockAllTimeCategorySalesRatio();
       break;

     case ChartFilterType.yearly:
       // Tạo dữ liệu giả theo tháng cho năm cụ thể
       if (selectedYear != null) {
         for (int i = 1; i <= 12; i++) {
           final monthYear = '${selectedYear}-${i.toString().padLeft(2, '0')}';

            final baseRevenue = 50000000.0 + (selectedYear - 2020) * 50000000.0 + i * 5000000.0; // Doanh thu tăng qua các năm và trong năm
            final revenue = baseRevenue + random.nextDouble() * 20000000.0 - 10000000.0;
            final profit = revenue * (0.2 + random.nextDouble() * 0.05);
            final baseQuantity = 100 + (selectedYear - 2020) * 50 + i * 5;
            final quantity = baseQuantity + random.nextInt(20);


           timeSeriesRevenueProfitData.add(TimeBasedChartData(timePeriod: monthYear, revenue: revenue > 0 ? revenue : 1000000, profit: profit > 0 ? profit : 500000));
           timeSeriesQuantityData.add(TimeBasedChartData(timePeriod: monthYear, quantitySold: quantity > 0 ? quantity : 10));
         }
       }
        categorySalesRatio = _createMockAllTimeCategorySalesRatio();
       break;

     case ChartFilterType.allTime:
       // Tạo dữ liệu giả theo tháng cho toàn bộ thời gian (ví dụ 3 năm gần nhất)
        for (int y = now.year - 2; y <= now.year; y++) { // 3 năm gần nhất
            for (int m = 1; m <= 12; m++) {
                if (y == now.year && m > now.month) break; // Chỉ đến tháng hiện tại của năm nay

                final monthYear = '${y}-${m.toString().padLeft(2, '0')}';
                final baseRevenue = 50000000.0 + (y - (now.year - 2)) * 100000000.0 + m * 5000000.0;
                final revenue = baseRevenue + random.nextDouble() * 30000000.0 - 15000000.0;
                final profit = revenue * (0.2 + random.nextDouble() * 0.05);
                final baseQuantity = 100 + (y - (now.year - 2)) * 100 + m * 10;
                final quantity = baseQuantity + random.nextInt(30);


                timeSeriesRevenueProfitData.add(TimeBasedChartData(timePeriod: monthYear, revenue: revenue > 0 ? revenue : 1000000, profit: profit > 0 ? profit : 500000));
                timeSeriesQuantityData.add(TimeBasedChartData(timePeriod: monthYear, quantitySold: quantity > 0 ? quantity : 10));
            }
        }
        categorySalesRatio = _createMockAllTimeCategorySalesRatio();

       break;
   }

   // Dữ liệu tỷ lệ danh mục toàn thời gian mặc định nếu chưa được gán
   if (categorySalesRatio.isEmpty) {
        categorySalesRatio = _createMockAllTimeCategorySalesRatio();
   }


   // Trả về đối tượng DashboardData giả
   return DashboardData(
      totalUsers: fakeTotalUsers,
      totalOrders: fakeTotalOrders,
      totalProductTypes: fakeTotalProductTypes,
      totalProducts: fakeTotalProducts,
      timeSeriesRevenueProfitData: timeSeriesRevenueProfitData,
      timeSeriesQuantityData: timeSeriesQuantityData,
      categorySalesRatio: categorySalesRatio,
   );
}

// Helper riêng để tạo dữ liệu tỷ lệ danh mục toàn thời gian
List<CategorySalesData> _createMockAllTimeCategorySalesRatio() {
    final random = Random();
    return [
        CategorySalesData(categoryName: 'Laptops', totalQuantitySold: 4000 + random.nextInt(1000)),
        CategorySalesData(categoryName: 'Monitors', totalQuantitySold: 2500 + random.nextInt(500)),
        CategorySalesData(categoryName: 'Keyboards & Mice', totalQuantitySold: 3000 + random.nextInt(700)),
        CategorySalesData(categoryName: 'SSDs & HDDs', totalQuantitySold: 2100 + random.nextInt(500)),
        CategorySalesData(categoryName: 'RAM Modules', totalQuantitySold: 1800 + random.nextInt(300)),
        CategorySalesData(categoryName: 'Motherboards', totalQuantitySold: 1000 + random.nextInt(200)),
        CategorySalesData(categoryName: 'Graphic Cards', totalQuantitySold: 2200 + random.nextInt(600)),
        CategorySalesData(categoryName: 'Webcams', totalQuantitySold: 500 + random.nextInt(200)),
        CategorySalesData(categoryName: 'Speakers', totalQuantitySold: 600 + random.nextInt(250)),
        CategorySalesData(categoryName: 'Headsets', totalQuantitySold: 700 + random.nextInt(300)),
    ];
}


// --- Mock Dashboard Provider ---

// Mock Provider để cung cấp dữ liệu DashboardData giả cho UI
class MockDashboardProvider with ChangeNotifier {
  // Lưu trữ dữ liệu DashboardData giả
  DashboardData? _dashboardData;
  DashboardData? get dashboardData => _dashboardData;

  // Trạng thái loading và error
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- State bộ lọc (cần thiết để Mock Provider phản hồi bộ lọc) ---
  ChartFilterType _currentFilterType = ChartFilterType.weekly; // Mặc định
  ChartFilterType get currentFilterType => _currentFilterType;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  int? _selectedMonth;
  int? get selectedMonth => _selectedMonth;

  int? _selectedYear;
  int? get selectedYear => _selectedYear;
  // ------------------------


  MockDashboardProvider() {
     // Thiết lập bộ lọc mặc định ban đầu cho mock data
    _currentFilterType = ChartFilterType.weekly;
    // Có thể thiết lập mặc định khác nếu muốn
    // final now = DateTime.now();
    // _currentFilterType = ChartFilterType.yearly;
    // _selectedYear = now.year;

    fetchData(); // Fetch dữ liệu giả lần đầu khi Provider được tạo
  }

  // Phương thức để thay đổi bộ lọc
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

    _dashboardData = null; // Reset dữ liệu cũ để hiển thị loading mới
    _errorMessage = null; // Reset lỗi

    notifyListeners(); // Thông báo UI rằng bộ lọc đã thay đổi và bắt đầu loading

    fetchData(); // Fetch dữ liệu giả mới với bộ lọc mới
  }


  // Phương thức giả lập việc fetch dữ liệu
  Future<void> fetchData() async {
    _isLoading = true;
    // notifyListeners(); // Tùy chọn: gọi ở đây để hiển thị loading spinner ngay lập tức

    // Giả lập độ trễ mạng
    Future.delayed(const Duration(milliseconds: 800), () {
      try {
         // Gọi hàm tạo dữ liệu giả mới và truyền tham số lọc hiện tại
         _dashboardData = _createMockDashboardDataWithFilter(
           filterType: _currentFilterType,
           startDate: _startDate,
           endDate: _endDate,
           selectedMonth: _selectedMonth,
           selectedYear: _selectedYear,
         );
         _errorMessage = null; // Đảm bảo không có lỗi giả sau khi tạo data thành công
      } catch (e) {
         // Nếu có lỗi khi tạo dữ liệu giả (ít xảy ra), lưu lỗi lại
         _errorMessage = 'Failed to create mock data: $e';
         _dashboardData = null; // Reset dữ liệu nếu tạo lỗi
      } finally {
         _isLoading = false;
         notifyListeners(); // Thông báo kết thúc loading và dữ liệu đã sẵn sàng (hoặc có lỗi)
      }
    });
  }

  // Implement phương thức refreshData
  Future<void> refreshData() async {
     if (!_isLoading) {
        await fetchData(); // Gọi lại fetchData để fetch dữ liệu giả mới
     }
  }

  // --- Getters để truy cập dữ liệu biểu đồ từ _dashboardData ---
  // Các getter này giống với getter trong Provider thật để widget có thể dùng chung
  List<TimeBasedChartData>? get timeSeriesRevenueProfitData => _dashboardData?.timeSeriesRevenueProfitData;
  List<TimeBasedChartData>? get timeSeriesQuantityData => _dashboardData?.timeSeriesQuantityData;
  List<CategorySalesData>? get filteredCategorySalesRatio => _dashboardData?.categorySalesRatio;

  // --- Getters để truy cập các chỉ số tổng từ _dashboardData ---
   int get totalUsers => _dashboardData?.totalUsers ?? 0;
   int get totalOrders => _dashboardData?.totalOrders ?? 0;
   int get totalProductTypes => _dashboardData?.totalProductTypes ?? 0;
   int get totalProducts => _dashboardData?.totalProducts ?? 0;

}