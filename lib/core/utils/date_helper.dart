class DateHelper {
  static const int addisAbabaOffsetHours = 3;

  /// Converts a given UTC DateTime to Addis Ababa local business time (UTC+3)
  static DateTime toAddisAbabaTime(DateTime utcTime) {
    final utc = utcTime.isUtc ? utcTime : utcTime.toUtc();
    return utc.add(const Duration(hours: addisAbabaOffsetHours));
  }

  /// Returns current time in Addis Ababa (UTC+3)
  static DateTime nowInAddisAbaba() {
    return toAddisAbabaTime(DateTime.now().toUtc());
  }

  /// Formats date ISO string for Addis Ababa business day: "YYYY-MM-DD"
  static String formatAddisAbabaDate(DateTime date) {
    final addisDate = date.isUtc ? toAddisAbabaTime(date) : date;
    final y = addisDate.year.toString().padLeft(4, '0');
    final m = addisDate.month.toString().padLeft(2, '0');
    final d = addisDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Checks if time string "HH:MM:SS" falls within open/close range
  static bool isWithinOperatingHours(String startStr, String endStr, String openStr, String closeStr) {
    return startStr.compareTo(openStr) >= 0 && endStr.compareTo(closeStr) <= 0;
  }
}
