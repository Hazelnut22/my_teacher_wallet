import 'package:intl/intl.dart';

class NumberFormatter {
  static final _mmkFormatter = NumberFormat('#,###', 'en_US');

  /// Formats a number with thousands separator: 1500000 → "1,500,000 MMK"
  static String mmk(double value) {
    return '${_mmkFormatter.format(value.toInt())} MMK';
  }

  /// Just the number with separator, no currency: 1500000 → "1,500,000"
  static String compact(double value) {
    return _mmkFormatter.format(value.toInt());
  }
}