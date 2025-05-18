import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/utils/chart_filter_type.dart';
import 'package:frontend_admin/models/category_sales_data.dart';
import 'package:frontend_admin/models/time_based_chart_data.dart';
import 'dart:math' as math;
import 'package:frontend_admin/providers/statistics_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          // Kiểm tra trạng thái loading dựa trên provider.isLoading
          if (provider.isLoading && provider.statisticsData == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: provider.refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (provider.statisticsData == null) {
            return const Center(child: Text('No dashboard data available.'));
          } else {
            final data = provider.statisticsData!; // Lấy DTO từ provider

            // Kiểm tra xem có bất kỳ dữ liệu biểu đồ nào được load không trong DTO
            bool hasChartData =
                (data.timeSeriesRevenueProfitData?.isNotEmpty ?? false) ||
                (data.timeSeriesQuantityData?.isNotEmpty ?? false) ||
                (data.categorySalesRatio?.isNotEmpty ?? false);

            // Hiển thị dashboard
            return SingleChildScrollView(
              // Cho phép cuộn toàn bộ nội dung
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hiển thị thông báo "No Chart Data" nếu không có dữ liệu biểu đồ sau khi load
                  if (!hasChartData &&
                      !provider.isLoading &&
                      provider.errorMessage == null) ...[
                    const SizedBox(height: 30), // Khoảng cách trước thông báo
                    const Center(
                      child: Text(
                        'No chart data available for the selected period.',
                      ),
                    ),
                  ],

                  Text(
                    'Biểu đồ phân tích doanh số',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Selection UI có thể thêm ở đây
                  _buildFilterSelectionUI(context, provider),
                  const SizedBox(height: 20),

                  // Revenue and Profit Chart
                  if (data.timeSeriesRevenueProfitData != null &&
                      data.timeSeriesRevenueProfitData!.isNotEmpty)
                    _buildChartCard(
                      context,
                      _getSalesChartTitle(provider),
                      LineChart(
                        _buildLineChartData(data.timeSeriesRevenueProfitData!),
                      ),
                      height: 300,
                    ),

                  // Products Sold Chart
                  if (data.timeSeriesQuantityData != null &&
                      data.timeSeriesQuantityData!.isNotEmpty)
                    _buildChartCard(
                      context,
                      _getTotalSalesChartTitle(provider),
                      BarChart(
                        _buildBarChartData(
                          context,
                          data.timeSeriesQuantityData!,
                        ),
                      ),
                      height: 300,
                    ),

                  // Category Sales Ratio Chart
                  if (data.categorySalesRatio != null &&
                      data.categorySalesRatio!.isNotEmpty)
                    _buildChartCard(
                      context,
                      _getCategoryRatioChartTitle(provider),
                      PieChart(_buildPieChartData(data.categorySalesRatio!)),
                      height: 300,
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to build a card container for charts (giữ nguyên như file bạn gửi)
  Widget _buildChartCard(
    BuildContext context,
    String title,
    Widget chartWidget, {
    double height = 250,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              height: height, // Sử dụng chiều cao được truyền vào
              child: chartWidget, // Widget biểu đồ
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods cho UI Chọn Bộ Lọc (Thêm vào) ---
  Widget _buildFilterSelectionUI(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<ChartFilterType>(
            decoration: const InputDecoration(
              labelText: 'Lọc theo',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 15,
              ),
            ),
            value: provider.currentFilterType,
            items:
                ChartFilterType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_filterTypeToString(type)),
                  );
                }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                provider.setFilter(filterType: newValue);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: _buildFilterValueInput(context, provider)),
      ],
    );
  }

  // Helper hiển thị UI nhập giá trị lọc tùy theo loại
  Widget _buildFilterValueInput(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    switch (provider.currentFilterType) {
      case ChartFilterType.weekly:
        return Container(
          alignment: Alignment.centerLeft,
          height: 56,
          child: const Text('7 ngày qua', style: TextStyle(fontSize: 16)),
        );
      case ChartFilterType.dateRange:
        return Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, provider, isStartDate: true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    provider.startDate == null
                        ? 'Chọn ngày'
                        : DateFormat('dd/MM/yyyy').format(provider.startDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, provider, isStartDate: false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày kết thúc',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    provider.endDate == null
                        ? 'Chọn ngày'
                        : DateFormat('dd/MM/yyyy').format(provider.endDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        );
      case ChartFilterType.monthly:
        final now = DateTime.now();
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tháng',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                value: provider.selectedMonth ?? now.month,
                items:
                    List.generate(12, (index) => index + 1).map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          DateFormat('MMMM').format(DateTime(now.year, month)),
                        ),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setFilter(
                      filterType: ChartFilterType.monthly,
                      selectedMonth: newValue,
                      selectedYear: provider.selectedYear ?? now.year,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Năm',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                value: provider.selectedYear ?? now.year,
                items:
                    List.generate(10, (index) => now.year - index).map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setFilter(
                      filterType: ChartFilterType.monthly,
                      selectedMonth: provider.selectedMonth ?? now.month,
                      selectedYear: newValue,
                    );
                  }
                },
              ),
            ),
          ],
        );
      case ChartFilterType.quarterly:
        final now = DateTime.now();
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Quý',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                value: provider.selectedQuarter ?? ((now.month - 1) ~/ 3) + 1,
                items:
                    List.generate(4, (index) => index + 1).map((quarter) {
                      return DropdownMenuItem(
                        value: quarter,
                        child: Text('Q$quarter'),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setFilter(
                      filterType: ChartFilterType.quarterly,
                      selectedQuarter: newValue,
                      selectedYear: provider.selectedYear ?? now.year,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Năm',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                value: provider.selectedYear ?? now.year,
                items:
                    List.generate(10, (index) => now.year - index).map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setFilter(
                      filterType: ChartFilterType.quarterly,
                      selectedQuarter: provider.selectedQuarter ?? 1,
                      selectedYear: newValue,
                    );
                  }
                },
              ),
            ),
          ],
        );
      case ChartFilterType.yearly:
        final now = DateTime.now();
        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Năm',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
          value: provider.selectedYear ?? now.year,
          items:
              List.generate(10, (index) => now.year - index).map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              provider.setFilter(
                filterType: ChartFilterType.yearly,
                selectedYear: newValue,
              );
            }
          },
        );
    }
  }

  // Helper hiển thị Date Picker
  Future<void> _selectDate(
    BuildContext context,
    StatisticsProvider provider, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (provider.startDate ?? DateTime.now())
              : (provider.endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final newStartDate = isStartDate ? picked : provider.startDate;
      final newEndDate = isStartDate ? provider.endDate : picked;
      provider.setFilter(
        filterType: ChartFilterType.dateRange,
        startDate: newStartDate,
        endDate: newEndDate,
      );
    }
  }

  // Helper chuyển đổi enum sang String hiển thị
  String _filterTypeToString(ChartFilterType type) {
    switch (type) {
      case ChartFilterType.weekly:
        return 'Theo tuần';
      case ChartFilterType.dateRange:
        return 'Khoảng thời gian';
      case ChartFilterType.monthly:
        return 'Theo tháng';
      case ChartFilterType.yearly:
        return 'Theo năm';
      case ChartFilterType.quarterly:
        return 'Theo quý';
    }
  }

  // Helper lấy tiêu đề động cho biểu đồ Doanh thu/Lợi nhuận
  String _getSalesChartTitle(StatisticsProvider provider) {
    switch (provider.currentFilterType) {
      case ChartFilterType.dateRange:
        if (provider.startDate != null && provider.endDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(provider.startDate!);
          final end = DateFormat('dd/MM/yyyy').format(provider.endDate!);
          return 'Doanh thu và Lợi nhuận ($start đến $end)';
        } else if (provider.startDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(provider.startDate!);
          return 'Doanh thu và Lợi nhuận (Từ $start)';
        } else if (provider.endDate != null) {
          final end = DateFormat('dd/MM/yyyy').format(provider.endDate!);
          return 'Doanh thu và Lợi nhuận (Đến $end)';
        }
        return 'Doanh thu và Lợi nhuận (Theo khoảng thời gian)';
      case ChartFilterType.monthly:
        if (provider.selectedMonth != null && provider.selectedYear != null) {
          final monthName = DateFormat(
            'MMMM',
          ).format(DateTime(provider.selectedYear!, provider.selectedMonth!));
          return 'Doanh thu và Lợi nhuận trong $monthName ${provider.selectedYear}';
        } else if (provider.selectedYear != null) {
          return 'Doanh thu và Lợi nhuận trong ${provider.selectedYear}';
        }
        return 'Doanh thu và Lợi nhuận (Theo tháng/năm)';
      case ChartFilterType.yearly:
        if (provider.selectedYear != null) {
          return 'Doanh thu và Lợi nhuận trong ${provider.selectedYear}';
        }
        return 'Doanh thu và Lợi nhuận (Theo năm)';
      case ChartFilterType.quarterly:
        return 'Doanh thu và Lợi nhuận (Theo quý)';
      case ChartFilterType.weekly:
        return 'Doanh thu và Lợi nhuận (7 ngày qua)';
    }
  }

  // Helper lấy tiêu đề động cho biểu đồ Sản phẩm bán ra
  String _getTotalSalesChartTitle(StatisticsProvider provider) {
    switch (provider.currentFilterType) {
      case ChartFilterType.dateRange:
        if (provider.startDate != null && provider.endDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(provider.startDate!);
          final end = DateFormat('dd/MM/yyyy').format(provider.endDate!);
          return 'Số lượng sản phẩm bán ra ($start đến $end)';
        } else if (provider.startDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(provider.startDate!);
          return 'Số lượng sản phẩm bán ra (Từ $start)';
        } else if (provider.endDate != null) {
          final end = DateFormat('dd/MM/yyyy').format(provider.endDate!);
          return 'Số lượng sản phẩm bán ra (Đến $end)';
        }
        return 'Số lượng sản phẩm bán ra (Theo khoảng thời gian)';
      case ChartFilterType.monthly:
        if (provider.selectedMonth != null && provider.selectedYear != null) {
          final monthName = DateFormat(
            'MMMM',
          ).format(DateTime(provider.selectedYear!, provider.selectedMonth!));
          return 'Số lượng sản phẩm bán ra trong $monthName ${provider.selectedYear}';
        } else if (provider.selectedYear != null) {
          return 'Số lượng sản phẩm bán ra trong ${provider.selectedYear}';
        }
        return 'Số lượng sản phẩm bán ra (Theo tháng/năm)';
      case ChartFilterType.yearly:
        if (provider.selectedYear != null) {
          return 'Số lượng sản phẩm bán ra trong ${provider.selectedYear}';
        }
        return 'Số lượng sản phẩm bán ra trong ${DateTime.now().year}';
      case ChartFilterType.quarterly:
        return 'Số lượng sản phẩm bán ra (Theo quý)';
      case ChartFilterType.weekly:
        return 'Số lượng sản phẩm bán ra (7 ngày qua)';
    }
  }

  // Helper lấy tiêu đề động cho biểu đồ Tỷ lệ danh mục
  String _getCategoryRatioChartTitle(StatisticsProvider provider) {
    switch (provider.currentFilterType) {
      case ChartFilterType.dateRange:
        if (provider.startDate != null && provider.endDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(provider.startDate!);
          final end = DateFormat('dd/MM/yyyy').format(provider.endDate!);
          return 'Tỉ lệ sản phẩm bán ra theo danh mục ($start đến $end)';
        } else if (provider.startDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(provider.startDate!);
          return 'Tỉ lệ sản phẩm bán ra theo danh mục (Từ $start)';
        } else if (provider.endDate != null) {
          final end = DateFormat('dd/MM/yyyy').format(provider.endDate!);
          return 'Tỉ lệ sản phẩm bán ra theo danh mục (Đến $end)';
        }
        return 'Tỉ lệ sản phẩm bán ra theo danh mục (Theo khoảng thời gian)';
      case ChartFilterType.monthly:
        if (provider.selectedMonth != null && provider.selectedYear != null) {
          final monthName = DateFormat(
            'MMMM',
          ).format(DateTime(provider.selectedYear!, provider.selectedMonth!));
          return 'Tỉ lệ sản phẩm bán ra theo danh mục trong $monthName ${provider.selectedYear}';
        } else if (provider.selectedYear != null) {
          return 'Tỉ lệ sản phẩm bán ra theo danh mục trong ${provider.selectedYear}';
        }
        return 'Tỉ lệ sản phẩm bán ra theo danh mục (Theo tháng/năm)';
      case ChartFilterType.yearly:
        if (provider.selectedYear != null) {
          return 'Tỉ lệ sản phẩm bán ra theo danh mục trong ${provider.selectedYear}';
        }
        return 'Tỉ lệ sản phẩm bán ra theo danh mục (Theo năm)';
      case ChartFilterType.quarterly:
        return 'Tỉ lệ sản phẩm bán ra theo danh mục (Theo quý)';
      case ChartFilterType.weekly:
        return 'Tỉ lệ sản phẩm bán ra theo danh mục (7 ngày qua)';
    }
  }

  // --- Helper Methods Vẽ Biểu đồ (Cập nhật để nhận List<TimeBasedChartData>) ---

  LineChartData _buildLineChartData(List<TimeBasedChartData> data) {
    data.sort(
      (a, b) => a.timePeriod.compareTo(b.timePeriod),
    ); // Sắp xếp theo timePeriod

    List<FlSpot> revenueSpots = [];
    List<FlSpot> profitSpots = [];
    List<String> labels = []; // Để hiển thị nhãn trên trục X

    for (int i = 0; i < data.length; i++) {
      // Chỉ thêm spot nếu có dữ liệu tương ứng
      if (data[i].revenue != null) {
        revenueSpots.add(FlSpot(i.toDouble(), data[i].revenue!));
      }
      if (data[i].profit != null) {
        profitSpots.add(FlSpot(i.toDouble(), data[i].profit!));
      }

      // Tạo nhãn từ timePeriod. Logic định dạng có thể phức tạp hơn tùy vào format của timePeriod
      String label = data[i].timePeriod;
      try {
        if (data.length <= 7 && data[i].timePeriod.length >= 8) {
          final date = DateTime.parse(data[i].timePeriod);
          label = DateFormat('dd/MM').format(date);
        } else if (data[i].timePeriod.length == 7) {
          final parts = data[i].timePeriod.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          label = DateFormat('MM/yyyy').format(DateTime(year, month));
        } else if (data[i].timePeriod.length == 4) {
          label = data[i].timePeriod;
        }
      } catch (e) {
        // ignore formatting error, use original label
      }
      labels.add(label);
    }

    // Tìm giá trị lớn nhất trên trục Y (cả doanh thu và lợi nhuận từ các spot)
    double maxY = 0;
    if (revenueSpots.isNotEmpty) {
      maxY = revenueSpots.map((spot) => spot.y).reduce(math.max);
    }
    if (profitSpots.isNotEmpty) {
      maxY = math.max(maxY, profitSpots.map((spot) => spot.y).reduce(math.max));
    }
    maxY = maxY * 1.2; // Thêm khoảng đệm
    if (maxY == 0) maxY = 1.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY > 0 ? maxY / 5 : 1.0,
        verticalInterval: 1.0,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Color(0xffe7e7e7), strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Color(0xffe7e7e7), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1.0,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < labels.length) {
                bool rotate = labels.length > 6 || labels[index].length > 5;
                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  angle: rotate ? -45 : 0,
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return SideTitleWidget(meta: meta, child: Container());
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY > 0 ? maxY / 5 : 1.0,
            getTitlesWidget: (value, meta) {
              String text;
              if (value >= 1000000) {
                text = '${(value / 1000000).toStringAsFixed(1)}M';
              } else if (value >= 1000) {
                text = '${(value / 1000).toStringAsFixed(0)}k';
              } else {
                text = value.toInt().toString();
              }
              return SideTitleWidget(
                meta: meta,
                space: 4.0,
                child: Text(text, style: const TextStyle(fontSize: 10)),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: (data.length > 0 ? data.length - 1 : 0).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: revenueSpots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: profitSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipMargin: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final isRevenue = touchedSpot.barIndex == 0;
              return LineTooltipItem(
                _formatCurrency(touchedSpot.y),
                TextStyle(
                  color: isRevenue ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '\n${isRevenue ? 'Doanh thu' : 'Lợi nhuận'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  BarChartData _buildBarChartData(
    BuildContext context,
    List<TimeBasedChartData> data,
  ) {
    data.sort((a, b) => a.timePeriod.compareTo(b.timePeriod));

    List<BarChartGroupData> barGroups = [];
    List<String> labels = [];

    double maxY = 0;
    if (data.isNotEmpty) {
      final quantities = data
          .where((item) => item.quantitySold != null)
          .map((item) => item.quantitySold!);
      if (quantities.isNotEmpty) {
        maxY = quantities.reduce(math.max).toDouble();
      }
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 1.0;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item.quantitySold != null) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: item.quantitySold!.toDouble(),
                color: Colors.indigo.shade400,
                width: 16,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.indigo.withOpacity(0.05),
                ),
              ),
            ],
          ),
        );
      } else {
        barGroups.add(BarChartGroupData(x: i, barRods: []));
      }

      String label = item.timePeriod;
      try {
        if (data.length <= 7 && item.timePeriod.length >= 8) {
          final date = DateTime.parse(item.timePeriod);
          label = DateFormat('dd/MM').format(date);
        } else if (item.timePeriod.length == 7) {
          final parts = item.timePeriod.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          label = DateFormat('MM/yyyy').format(DateTime(year, month));
        } else if (item.timePeriod.length == 4) {
          label = item.timePeriod;
        }
      } catch (e) {}
      labels.add(label);
    }

    return BarChartData(
      barGroups: barGroups,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      maxY: maxY,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < labels.length) {
                bool rotate = labels.length > 6 || labels[index].length > 5;
                return SideTitleWidget(
                  meta: meta,
                  space: 4.0,
                  angle: rotate ? -45 : 0,
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return SideTitleWidget(meta: meta, child: Container());
            },
            interval: 1.0,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY > 0 ? maxY / 5 : 1.0,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                space: 4.0,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
            reservedSize: 28,
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.toInt()} sản phẩm',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    );
  }

  PieChartData _buildPieChartData(List<CategorySalesData> data) {
    List<PieChartSectionData> sections = [];
    double totalSold = 0;
    if (data.isNotEmpty) {
      totalSold =
          data
              .map((item) => item.totalQuantitySold)
              .reduce((a, b) => a + b)
              .toDouble();
    }

    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.pink,
      Colors.amber,
    ];

    data.sort((a, b) => b.totalQuantitySold.compareTo(a.totalQuantitySold));

    for (int i = 0; i < data.length; i++) {
      final category = data[i];
      if (category.totalQuantitySold > 0) {
        final double percentage =
            totalSold > 0 ? (category.totalQuantitySold / totalSold) * 100 : 0;
        sections.add(
          PieChartSectionData(
            value: category.totalQuantitySold.toDouble(),
            color: colors[i % colors.length],
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
            badgeWidget: _buildBadge(category.categoryName),
            badgePositionPercentageOffset: .98,
          ),
        );
      }
    }

    return PieChartData(
      sections: sections,
      borderData: FlBorderData(show: false),
      sectionsSpace: 0,
      centerSpaceRadius: 40,
    );
  }

  Widget _buildBadge(String text) {
    String display = text.length > 15 ? '${text.substring(0, 12)}...' : text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        display,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  // Thêm hàm _formatCurrency
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
