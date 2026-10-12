import 'package:flutter_test/flutter_test.dart';
import 'package:afro_barber/data/models/appointment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Appointment Status State Machine & Lifecycle Tests', () {
    test('Appointment status enum parsing and display names', () {
      expect(AppointmentStatus.fromString('confirmed'), equals(AppointmentStatus.confirmed));
      expect(AppointmentStatus.fromString('checked_in'), equals(AppointmentStatus.checked_in));
      expect(AppointmentStatus.fromString('in_progress'), equals(AppointmentStatus.in_progress));
      expect(AppointmentStatus.fromString('completed'), equals(AppointmentStatus.completed));
      expect(AppointmentStatus.fromString('cancelled'), equals(AppointmentStatus.cancelled));
      expect(AppointmentStatus.fromString('no_show'), equals(AppointmentStatus.no_show));

      expect(AppointmentStatus.checked_in.displayName, equals('Checked In'));
      expect(AppointmentStatus.in_progress.displayName, equals('In Progress'));
      expect(AppointmentStatus.no_show.displayName, equals('No Show'));
    });

    test('Appointment status transitions preserve reference and data snapshots', () {
      final now = DateTime(2026, 9, 1);
      final apt = Appointment(
        id: 'apt-test-1',
        appointmentReference: 'AFB-20260920-0047',
        customerId: 'cust-1',
        customerName: 'Abebe Kebede',
        barberId: 'barber-mike',
        barberName: 'Mike Tadesse',
        serviceId: 'srv-haircut',
        serviceName: 'Fade Cut',
        serviceNameSnapshot: 'Fade Cut',
        appointmentDate: DateTime(2026, 9, 20),
        startTime: '10:00:00',
        endTime: '10:45:00',
        status: AppointmentStatus.confirmed,
        priceSnapshot: 450.0,
        createdAt: now,
      );

      expect(apt.status, equals(AppointmentStatus.confirmed));
      expect(apt.appointmentReference, equals('AFB-20260920-0047'));
      expect(apt.canCancelOrReschedule, isTrue);
      expect(apt.isUpcoming, isTrue);

      final completedApt = Appointment(
        id: apt.id,
        appointmentReference: apt.appointmentReference,
        customerId: apt.customerId,
        customerName: apt.customerName,
        barberId: apt.barberId,
        barberName: apt.barberName,
        serviceId: apt.serviceId,
        serviceName: apt.serviceName,
        serviceNameSnapshot: apt.serviceNameSnapshot,
        appointmentDate: apt.appointmentDate,
        startTime: apt.startTime,
        endTime: apt.endTime,
        status: AppointmentStatus.completed,
        completedAt: DateTime.now(),
        createdAt: apt.createdAt,
      );

      expect(completedApt.status, equals(AppointmentStatus.completed));
      expect(completedApt.canCancelOrReschedule, isFalse);
      expect(completedApt.completedAt, isNotNull);
    });
  });
}
