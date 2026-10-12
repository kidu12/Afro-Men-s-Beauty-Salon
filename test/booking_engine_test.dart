import 'package:flutter_test/flutter_test.dart';
import 'package:afro_barber/data/mock/mock_data_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Engine & Double-Booking Prevention Tests', () {
    late MockDataStore store;

    setUp(() {
      store = MockDataStore.instance;
    });

    test('Available slots generation respects shop operating hours and intervals', () {
      final testDate = DateTime(2026, 9, 1); // Tuesday
      final slots = store.calculateAvailableSlots(
        barberId: 'barber-mike',
        durationMinutes: 45,
        date: testDate,
      );

      expect(slots.isNotEmpty, isTrue);
      expect(slots.first.timeString, equals('09:00:00'));
      expect(slots.first.isAvailable, isTrue);
    });

    test('Slots duration calculation properly chunks day into slots', () {
      final testDate = DateTime(2026, 9, 2); // Wednesday
      final slots30 = store.calculateAvailableSlots(
        barberId: 'barber-abel',
        durationMinutes: 30,
        date: testDate,
      );
      final slots60 = store.calculateAvailableSlots(
        barberId: 'barber-abel',
        durationMinutes: 60,
        date: testDate,
      );

      expect(slots30.length, greaterThan(slots60.length));
    });
  });
}
