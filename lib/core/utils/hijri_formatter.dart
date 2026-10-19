import 'package:hijri/hijri_calendar.dart';

class HijriFormatter {
  static String formatHijri(DateTime date) {
    HijriCalendar.setLocal('ar'); // Ensure Arabic names
    var hijriDate = HijriCalendar.fromDate(date);
    return hijriDate.toFormat('dd MMMM yyyy'); // Example: 01 Muharram 1445
  }

  static String formatBoth(DateTime date) {
    final gregorian = "${date.day}/${date.month}/${date.year}";
    final hijri = formatHijri(date);
    return "$gregorian ($hijri)";
  }
}
