import 'package:intl/intl.dart';

class SarFormatter {
  static String format(dynamic amount) {
    if (amount == null) return 'SAR 0.00';
    num val = 0;
    if (amount is num) {
      val = amount;
    } else if (amount is String) {
      val = num.tryParse(amount) ?? 0;
    }
    
    final formatter = NumberFormat.currency(
      symbol: 'SAR ',
      decimalDigits: 2,
    );
    return formatter.format(val);
  }

  static String formatArabic(dynamic amount) {
    if (amount == null) return '٠٫٠٠ ر.س';
    num val = 0;
    if (amount is num) {
      val = amount;
    } else if (amount is String) {
      val = num.tryParse(amount) ?? 0;
    }
    
    final formatter = NumberFormat.currency(
      symbol: ' ر.س',
      decimalDigits: 2,
    );
    String formatted = formatter.format(val);
    return _toIndicNumerals(formatted);
  }

  static String _toIndicNumerals(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}
