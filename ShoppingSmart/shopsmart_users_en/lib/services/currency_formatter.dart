import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatVND(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.round())}₫';
  }

  static String formatVNDFromString(String amount) {
    try {
      final double value = double.parse(amount);
      return formatVND(value);
    } catch (e) {
      return '$amount₫';
    }
  }

  static String formatVNDFromInt(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}₫';
  }

  // Format for display in UI without currency symbol
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount.round());
  }

  // Parse formatted currency back to double
  static double parseVND(String formattedAmount) {
    try {
      String cleanAmount =
          formattedAmount.replaceAll('₫', '').replaceAll(',', '').trim();
      return double.parse(cleanAmount);
    } catch (e) {
      return 0.0;
    }
  }

  // For backward compatibility
  static String format(double amount) {
    return formatNumber(amount);
  }
}
