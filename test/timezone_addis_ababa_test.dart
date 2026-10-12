import 'package:flutter_test/flutter_test.dart';
import 'package:afro_barber/core/utils/date_helper.dart';
import 'package:afro_barber/data/mock/mock_data_store.dart';

void main() {
  group('Ethiopia (Africa/Addis_Ababa UTC+3) Timezone Tests', () {
    test('UTC time correctly shifts +3 hours for Addis Ababa business day', () {
      final utcMidnight = DateTime.utc(2026, 8, 21, 0, 0, 0);
      final addisTime = DateHelper.toAddisAbabaTime(utcMidnight);

      expect(addisTime.hour, equals(3));
      expect(addisTime.day, equals(21));
    });

    test('Late UTC evening (22:00 UTC) shifts to next calendar day in Addis Ababa', () {
      final lateUtc = DateTime.utc(2026, 8, 21, 22, 0, 0);
      final addisTime = DateHelper.toAddisAbabaTime(lateUtc);

      expect(addisTime.hour, equals(1));
      expect(addisTime.day, equals(22)); // Next day in Ethiopia!
      expect(DateHelper.formatAddisAbabaDate(lateUtc), equals('2026-08-22'));
    });

    test('Operating hours check strictly confines appointments inside business window', () {
      const openTime = '09:00:00';
      const closeTime = '20:00:00';

      // Within business hours
      expect(DateHelper.isWithinOperatingHours('09:00:00', '09:45:00', openTime, closeTime), isTrue);
      expect(DateHelper.isWithinOperatingHours('19:15:00', '20:00:00', openTime, closeTime), isTrue);

      // Outside business hours (too early or crossing closing time)
      expect(DateHelper.isWithinOperatingHours('08:30:00', '09:15:00', openTime, closeTime), isFalse);
      expect(DateHelper.isWithinOperatingHours('19:30:00', '20:15:00', openTime, closeTime), isFalse);
    });

    test('Sunday shop schedule opens at 10:00 and closes at 18:00', () {
      final sundayDate = DateTime(2026, 8, 23); // Sunday
      final slots = MockDataStore.instance.calculateAvailableSlots(
        barberId: 'barber-mike',
        durationMinutes: 45,
        date: sundayDate,
      );

      expect(slots.first.timeString, equals('10:00:00'));
      expect(slots.last.timeString, equals('17:00:00')); // 17:00 + 45 min <= 18:00 close
    });
  });
}
