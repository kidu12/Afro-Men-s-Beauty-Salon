import 'package:flutter_test/flutter_test.dart';
import 'package:afro_barber/core/utils/formatters.dart';
import 'package:afro_barber/data/models/service_item.dart';
import 'package:afro_barber/data/models/barber.dart';

void main() {
  group('Critical Pricing & Rating Business Rules Tests', () {
    test('Service with null price must return null and never "0 ETB"', () {
      const service = ServiceItem(
        id: 'srv-1',
        name: 'Signature Haircut',
        price: null,
        durationMinutes: 45,
      );

      expect(service.price, isNull);
      expect(service.hasPrice, isFalse);
      expect(Formatters.formatPrice(service.price), isNull);
      expect(Formatters.formatPrice(null), isNull);
    });

    test('Service with price returns formatted ETB string', () {
      const service = ServiceItem(
        id: 'srv-2',
        name: 'Deluxe Haircut',
        price: 450,
        durationMinutes: 45,
      );

      expect(service.price, equals(450));
      expect(service.hasPrice, isTrue);
      expect(Formatters.formatPrice(service.price), equals('450 ETB'));
    });

    test('Barber with 0 reviews or 0 rating must format as "New barber"', () {
      const newBarber = Barber(
        id: 'barber-daniel',
        profileId: 'prof-daniel',
        name: 'Daniel Haile',
        ratingAvg: 0.0,
        totalReviews: 0,
      );

      expect(newBarber.isNewBarber, isTrue);
      expect(Formatters.formatBarberRating(newBarber.ratingAvg, newBarber.totalReviews), equals('New barber'));
    });

    test('Barber with existing reviews formats with rating and count', () {
      const experiencedBarber = Barber(
        id: 'barber-mike',
        profileId: 'prof-mike',
        name: 'Mike Tadesse',
        ratingAvg: 4.9,
        totalReviews: 84,
      );

      expect(experiencedBarber.isNewBarber, isFalse);
      expect(Formatters.formatBarberRating(experiencedBarber.ratingAvg, experiencedBarber.totalReviews), equals('4.9 (84)'));
    });

    test('Service duration configuration verification', () {
      const unconfiguredService = ServiceItem(
        id: 'srv-unconfigured',
        name: 'Special Treatment',
        durationMinutes: null,
      );
      expect(unconfiguredService.isBookingConfigured, isFalse);

      const configuredService = ServiceItem(
        id: 'srv-configured',
        name: 'Beard Trim',
        durationMinutes: 20,
      );
      expect(configuredService.isBookingConfigured, isTrue);
      expect(Formatters.formatDuration(configuredService.durationMinutes), equals('20 min'));
    });
  });
}
