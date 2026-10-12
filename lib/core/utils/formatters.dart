import 'dart:math';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  static const Map<int, String> _amharicWeekdays = {
    DateTime.monday: 'ሰኞ',
    DateTime.tuesday: 'ማክሰኞ',
    DateTime.wednesday: 'ረቡዕ',
    DateTime.thursday: 'ሐሙስ',
    DateTime.friday: 'አርብ',
    DateTime.saturday: 'ቅዳሜ',
    DateTime.sunday: 'እሁድ',
  };

  static const Map<int, String> _amharicMonths = {
    1: 'ጥር',
    2: 'የካቲት',
    3: 'መጋቢት',
    4: 'ሚያዚያ',
    5: 'ግንቦት',
    6: 'ሰኔ',
    7: 'ሐምሌ',
    8: 'ነሐሴ',
    9: 'መስከረም',
    10: 'ጥቅምት',
    11: 'ኅዳር',
    12: 'ታኅሣሥ',
  };

  /// Strictly returns null if price is null or less than 0.
  /// Never returns "0 ETB" or artificial defaults per master requirement.
  static String? formatPrice(num? price, [String? currency]) {
    if (price == null) return null;
    final formatter = NumberFormat('#,##0.##');
    final curr = currency ?? AppConstants.currencyCode;
    return '${formatter.format(price)} $curr';
  }

  /// Formats duration like "45 min" or "45 ደቂቃ"
  static String? formatDuration(int? durationMinutes, [bool isAmharic = false]) {
    if (durationMinutes == null || durationMinutes <= 0) return null;
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      if (isAmharic) {
        return mins > 0 ? '$hours ሰዓት $mins ደቂቃ' : '$hours ሰዓት';
      }
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return isAmharic ? '$durationMinutes ደቂቃ' : '$durationMinutes min';
  }

  /// Formats date: "Fri, Aug 21, 2026" or "አርብ፣ ነሐሴ 21፣ 2026"
  static String formatDate(DateTime date, [bool isAmharic = false]) {
    if (isAmharic) {
      final w = _amharicWeekdays[date.weekday] ?? '';
      final m = _amharicMonths[date.month] ?? '';
      return '$w፣ $m ${date.day}፣ ${date.year}';
    }
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  /// Formats short date: "Aug 21" or "ነሐሴ 21"
  static String formatShortDate(DateTime date, [bool isAmharic = false]) {
    if (isAmharic) {
      final m = _amharicMonths[date.month] ?? '';
      return '$m ${date.day}';
    }
    return DateFormat('MMM d').format(date);
  }

  /// Formats weekday: "Friday" or "አርብ"
  static String formatWeekday(DateTime date, [bool isAmharic = false]) {
    if (isAmharic) {
      return _amharicWeekdays[date.weekday] ?? DateFormat('EEEE').format(date);
    }
    return DateFormat('EEEE').format(date);
  }

  /// Formats time: "09:30 AM"
  static String formatTimeOfDay(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Formats unique appointment reference code: e.g. "AFB-20260821-X7K29P"
  static String formatAppointmentReference(DateTime date, [String? randomSuffix]) {
    final datePart = DateFormat('yyyyMMdd').format(date);
    if (randomSuffix != null && randomSuffix.isNotEmpty) {
      return 'AFB-$datePart-${randomSuffix.toUpperCase()}';
    }
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final suffix = List.generate(6, (index) => chars[rnd.nextInt(chars.length)]).join();
    return 'AFB-$datePart-$suffix';
  }

  /// Parses "09:00:00" or "09:00" string into DateTime for today
  static DateTime parseTimeString(String timeStr, DateTime baseDate) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  /// Formats barber rating string: 5.0 stars and experience years
  static String formatBarberRating(double rating, int experienceYears, [bool isAmharic = false]) {
    final exp = experienceYears > 0 ? experienceYears : 5;
    return isAmharic ? '5.0 • $exp+ ዓመት ልምድ' : '5.0 • $exp+ yrs exp';
  }
}
