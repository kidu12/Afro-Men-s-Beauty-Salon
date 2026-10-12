import 'package:flutter_test/flutter_test.dart';
import 'package:afro_barber/data/models/appointment.dart';
import 'package:afro_barber/data/models/user_profile.dart';

void main() {
  group('Security & Role Authorization Invariants Tests', () {
    test('UserRole enum properly parses customer, barber, admin', () {
      expect(UserRole.fromString('customer'), equals(UserRole.customer));
      expect(UserRole.fromString('barber'), equals(UserRole.barber));
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('invalid'), equals(UserRole.customer)); // Safe default
    });

    test('Customer role cannot be created with elevated admin flag directly from client', () {
      final customer = UserProfile(
        id: 'user-sec-1',
        fullName: 'Abebe Bikila',
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );

      expect(customer.isAdmin, isFalse);
      expect(customer.isBarber, isFalse);
    });

    test('Admin role has administrative permissions', () {
      final admin = UserProfile(
        id: 'admin-sec-1',
        fullName: 'Shop Owner',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );

      expect(admin.isAdmin, isTrue);
    });
  });

  group('One-Tap Rebooking State Restoration Tests', () {
    test('Past appointment provides full snapshot data needed for rebooking', () {
      final pastApt = Appointment(
        id: 'past-rebook-1',
        appointmentReference: 'AFB-20260810-AB12CD',
        customerId: 'cust-1',
        customerName: 'Kidus Alemu',
        barberId: 'barber-mike',
        barberName: 'Mike Tadesse',
        serviceId: 'srv-haircut',
        serviceName: 'Signature Haircut',
        hairstyleId: 'style-1',
        hairstyleName: 'Low Drop Fade',
        appointmentDate: DateTime(2026, 8, 10),
        startTime: '14:00:00',
        endTime: '14:45:00',
        status: AppointmentStatus.completed,
        priceSnapshot: null,
        durationSnapshot: 45,
        serviceNameSnapshot: 'Signature Haircut',
        createdAt: DateTime(2026, 8, 8),
      );

      // Verify all required parameters for rebooking are preserved
      expect(pastApt.serviceId.isNotEmpty, isTrue);
      expect(pastApt.barberId.isNotEmpty, isTrue);
      expect(pastApt.hairstyleId, equals('style-1'));
      expect(pastApt.durationSnapshot, equals(45));
    });
  });
}
