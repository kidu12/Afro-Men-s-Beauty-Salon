import 'package:flutter_test/flutter_test.dart';
import 'package:afro_barber/core/utils/formatters.dart';

void main() {
  group('Appointment Reference Format & Uniqueness Tests', () {
    test('Generated reference matches strict format AFB-YYYYMMDD-XXXXXX', () {
      final testDate = DateTime(2026, 8, 21);
      final ref = Formatters.formatAppointmentReference(testDate);

      // Must start with AFB-20260821-
      expect(ref.startsWith('AFB-20260821-'), isTrue);
      // Total length: 4 (AFB-) + 8 (20260821) + 1 (-) + 6 (suffix) = 19
      expect(ref.length, equals(19));
      // Suffix must be uppercase alphanumeric
      final suffix = ref.split('-').last;
      expect(suffix.length, equals(6));
      expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(suffix), isTrue);
    });

    test('Explicit suffix is sanitized and formatted with uppercase', () {
      final testDate = DateTime(2026, 9, 15);
      final ref = Formatters.formatAppointmentReference(testDate, 'x7k29p');

      expect(ref, equals('AFB-20260915-X7K29P'));
    });

    test('Bulk reference generation produces unique codes without collisions', () {
      final testDate = DateTime(2026, 8, 21);
      final Set<String> generated = {};

      for (int i = 0; i < 1000; i++) {
        final ref = Formatters.formatAppointmentReference(testDate);
        expect(generated.contains(ref), isFalse, reason: 'Duplicate reference found: $ref');
        generated.add(ref);
      }

      expect(generated.length, equals(1000));
    });
  });
}
