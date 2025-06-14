import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_admin/models/category_sales_data.dart';
import 'package:frontend_admin/models/time_based_chart_data.dart';
import 'dart:math' as math;

import 'package:frontend_admin/providers/overview_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OverviewProvider>(
        builder: (context, provider, child) {
          // Kiểm tra trạng thái loading dựa trên provider.isLoading
          if (provider.isLoading && provider.overviewData == null) {
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
          } else if (provider.overviewData == null) {
            return const Center(child: Text('No dashboard data available.'));
          } else {
            final data = provider.overviewData!; // Lấy DTO từ provider

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
                  // --- Top Row: Key Metrics Grid ---
                  Text(
                    'Số liệu tổng quan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 1050
                            ? 2
                            : MediaQuery.of(context).size.width < 1300
                            ? 3
                            : 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.0, // Tỷ lệ khung hình cho ô metric
                    children: [
                      _buildMetricCard(
                        context,
                        'Tổng số người dùng',
                        data.totalUsers.toString(),
                        Icons.people,
                      ),
                      _buildMetricCard(
                        context,
                        'Tổng số đơn hàng',
                        data.totalOrders.toString(),
                        Icons.shopping_cart,
                      ),
                      _buildMetricCard(
                        context,
                        'Tổng số danh mục sản phẩm',
                        data.totalProductTypes.toString(),
                        Icons.category,
                      ),
                      _buildMetricCard(
                        context,
                        'Tổng số sản phẩm',
                        data.totalProducts.toString(),
                        Icons.inventory,
                      ),
                      _buildMetricCard(
                        context,
                        'Số người dùng mới',
                        data.newUsers.toString(),
                        FontAwesomeIcons.userPlus,
                      ),
                      _buildMetricCard(
                        context,
                        'Số đơn hàng mới',
                        data.newOrders.toString(),
                        FontAwesomeIcons.cartPlus,
                      ),
                      _buildMetricCard(
                        context,
                        'Tổng doanh thu',
                        _formatCurrency(data.totalRevenue),
                        FontAwesomeIcons.moneyBill,
                      ),
                      _buildMetricCard(
                        context,
                        'Tổng lợi nhuận',
                        _formatCurrency(data.totalProfit),
                        FontAwesomeIcons.moneyBillTrendUp,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (!hasChartData &&
                      !provider.isLoading &&
                      provider.errorMessage == null) ...[
                    const SizedBox(height: 30), // Khoảng cách trước thông báo
                    const Center(
                      child: Text(
                        'Không có dữ liệu biểu đồ nào có sẵn cho khoảng thời gian đã chọn.',
                      ),
                    ),
                  ],

                  // --- Lower Section: Charts ---
                  Text(
                    'Phân tích doanh số (7 ngày qua)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width < 1300 ? 1 : 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    children: [
                      // Revenue and Profit Chart
                      if (data.timeSeriesRevenueProfitData != null &&
                          data.timeSeriesRevenueProfitData!.isNotEmpty)
                        _buildChartCard(
                          context,
                          'Doanh thu và Lợi nhuận',
                          LineChart(
                            _buildLineChartData(
                              data.timeSeriesRevenueProfitData!,
                            ),
                          ),
                          height: 300,
                        ),

                      // Products Sold Chart
                      if (data.timeSeriesQuantityData != null &&
                          data.timeSeriesQuantityData!.isNotEmpty)
                        _buildChartCard(
                          context,
                          'Số lượng sản phẩm bán ra',
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
                          'Tỉ lệ sản phẩm bán ra theo danh mục',
                          PieChart(
                            _buildPieChartData(data.categorySalesRatio!),
                          ),
                          height: 300,
                        ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to build a metric card (giữ nguyên như file bạn gửi)
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.indigo,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20, // Kích thước font nhỏ hơn
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
              height: height,
              child: chartWidget,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format currency (assuming VND)
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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
      String label =
          data[i].timePeriod; // Ví dụ: "2023-10-26", "2023-10", "2023"
      // Cố gắng định dạng lại nhãn cho đẹp hơn tùy vào độ dài của list data hoặc format
      try {
        if (data.length <= 7 && data[i].timePeriod.length >= 8) {
          // Dữ liệu hàng ngày (ví dụ weekly hoặc dateRange ngắn)
          final date = DateTime.parse(data[i].timePeriod);
          label = DateFormat('dd/MM').format(date); // Ví dụ 26/10
        } else if (data[i].timePeriod.length == 7) {
          // Dữ liệu theo tháng (YYYY-MM)
          final parts = data[i].timePeriod.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          label = DateFormat(
            'MM/yyyy',
          ).format(DateTime(year, month)); // Ví dụ 10/2023
        } else if (data[i].timePeriod.length == 4) {
          // Dữ liệu theo năm (YYYY)
          label = data[i].timePeriod; // Giữ nguyên năm
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
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final value = touchedSpot.y.toDouble();
              final isRevenue = touchedSpot.barIndex == 0;
              
              return LineTooltipItem(
                _formatCurrency(value),
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
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toInt().toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
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
}
