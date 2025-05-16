class TimeBasedChartData {
  final String timePeriod; // Ví dụ: "2023-10-26", "2023-10", "2023"
  final double? revenue; // Nullable
  final double? profit;  // Nullable
  final int? quantitySold; // Nullable

  TimeBasedChartData({
    required this.timePeriod,
    this.revenue,
    this.profit,
    this.quantitySold,
  });

  factory TimeBasedChartData.fromJson(Map<String, dynamic> json) {
    return TimeBasedChartData(
      timePeriod: json['timePeriod'] as String,
      revenue: (json['revenue'] as num?)?.toDouble(), // Parse Nullable num sang Nullable double
      profit: (json['profit'] as num?)?.toDouble(),    // Parse Nullable num sang Nullable double
      quantitySold: json['quantitySold'] as int?,      // Parse Nullable int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timePeriod': timePeriod,
      'revenue': revenue,
      'profit': profit,
      'quantitySold': quantitySold,
    };
  }
}