import 'package:intl/intl.dart';

/// Formats a numeric value as a currency string in Vietnamese Dong (VND)
/// 
/// Example:
/// ```dart
/// formatCurrency(15000000) // Returns '15.000.000 ₫'
/// ```
/// 
/// Parameters:
///   - amount: The numeric amount to format
///   - symbol: The currency symbol (defaults to '₫')
///   - decimalDigits: Number of decimal places (defaults to 0 for VND)
///   
/// Returns a formatted currency string
String formatCurrency(
  double amount, {
  String symbol = '₫',
  int decimalDigits = 0,
}) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: symbol,
    decimalDigits: decimalDigits,
  );
  return formatter.format(amount);
}

/// Formats a numeric value as a compact currency (shortened form)
/// 
/// Example:
/// ```dart
/// formatCompactCurrency(1500000) // Returns '1.5M ₫'
/// ```
String formatCompactCurrency(double amount, {String symbol = '₫'}) {
  final formatter = NumberFormat.compactCurrency(
    locale: 'vi_VN',
    symbol: symbol,
    decimalDigits: 1,
  );
  return formatter.format(amount);
}

/// Parses a currency string back to a numeric value
/// 
/// Example:
/// ```dart
/// parseCurrency('15.000.000 ₫') // Returns 15000000.0
/// ```
double? parseCurrency(String currencyString) {
  try {
    final cleanString = currencyString
        .replaceAll(RegExp(r'[^\d,.]'), '') // Remove all non-numeric characters except . and ,
        .trim();
    
    // Handle both comma and period as decimal separators
    final formatter = NumberFormat.decimalPattern('vi_VN');
    return formatter.parse(cleanString).toDouble();
  } catch (e) {
    return null; // Return null if parsing fails
  }
}