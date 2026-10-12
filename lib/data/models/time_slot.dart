class TimeSlot {
  final String timeString; // "09:00:00"
  final String displayLabel; // "09:00 AM"
  final bool isAvailable;
  final String? reasonUnavailable;

  const TimeSlot({
    required this.timeString,
    required this.displayLabel,
    this.isAvailable = true,
    this.reasonUnavailable,
  });
}
