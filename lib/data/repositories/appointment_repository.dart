import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/time_slot.dart';
import '../services/supabase_service.dart';
import '../../core/errors/app_exceptions.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

class AppointmentRepository {
  Future<List<Appointment>> getAppointments({
    String? customerId,
    String? barberId,
  }) async {
    try {
      var query = SupabaseService.client
          .from('appointments')
          .select('*, barbers(profiles(full_name, avatar_url)), services(name, image_url)');

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }
      if (barberId != null) {
        query = query.eq('barber_id', barberId);
      }

      final res = await query.order('appointment_date', ascending: false);
      return (res as List<dynamic>)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[APPOINTMENT] getAppointments error: $e');
      return [];
    }
  }

  /// Computes available time slots client-side by checking existing appointments
  /// and barber days off against the barber's schedule for a given date.
  Future<List<TimeSlot>> getAvailableSlots({
    required String barberId,
    required String serviceId,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayOfWeek = date.weekday % 7; // Dart: Mon=1..Sun=7; DB: Sun=0..Sat=6

      // 1. Check if barber is on leave (day off) for this date
      try {
        final dayOffRes = await SupabaseService.client
            .from('barber_days_off')
            .select('id, reason')
            .eq('barber_id', barberId)
            .eq('off_date', dateStr);

        if (dayOffRes is List && dayOffRes.isNotEmpty) {
          // Barber is taking a day off on this specific date
          return [];
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[APPOINTMENT] Check days off error: $e');
      }

      // 2. Get the service duration
      int durationMins = 45;
      try {
        final serviceList = await SupabaseService.client
            .from('services')
            .select('duration_minutes')
            .eq('id', serviceId);

        if (serviceList is List && serviceList.isNotEmpty) {
          durationMins = (serviceList.first['duration_minutes'] as int?) ?? 45;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[APPOINTMENT] Get service duration error: $e');
      }

      // 3. Get barber schedule for this day of week
      String startTimeStr = '09:00:00';
      String endTimeStr = '21:00:00';
      bool isWorking = true;

      try {
        final schedList = await SupabaseService.client
            .from('barber_schedules')
            .select('start_time, end_time, is_working')
            .eq('barber_id', barberId)
            .eq('day_of_week', dayOfWeek);

        if (schedList is List && schedList.isNotEmpty) {
          final sched = schedList.first as Map<String, dynamic>;
          isWorking = (sched['is_working'] as bool?) ?? true;
          if (sched['start_time'] != null) startTimeStr = sched['start_time'] as String;
          if (sched['end_time'] != null) endTimeStr = sched['end_time'] as String;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[APPOINTMENT] Get schedule error: $e');
      }

      if (!isWorking) {
        return [];
      }

      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');
      var slotStart = DateTime(date.year, date.month, date.day,
          int.parse(startParts[0]), int.parse(startParts[1]));
      final schedEnd = DateTime(date.year, date.month, date.day,
          int.parse(endParts[0]), int.parse(endParts[1]));

      // 4. Get booked appointments for this barber on this date
      List<dynamic> bookedRes = [];
      try {
        final res = await SupabaseService.client
            .from('appointments')
            .select('start_time, end_time')
            .eq('barber_id', barberId)
            .eq('appointment_date', dateStr)
            .neq('status', 'cancelled')
            .neq('status', 'no_show');

        if (res is List) {
          bookedRes = res;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[APPOINTMENT] Get booked appointments error: $e');
      }

      final bookedSlots = bookedRes.map((b) {
        final sp = (b['start_time'] as String).split(':');
        final ep = (b['end_time'] as String).split(':');
        return (
          start: DateTime(date.year, date.month, date.day,
              int.parse(sp[0]), int.parse(sp[1])),
          end: DateTime(date.year, date.month, date.day,
              int.parse(ep[0]), int.parse(ep[1])),
        );
      }).toList();

      // 5. Generate 30-minute interval slots
      final slots = <TimeSlot>[];
      final now = DateTime.now();

      while (!slotStart.add(Duration(minutes: durationMins)).isAfter(schedEnd)) {
        final slotEnd = slotStart.add(Duration(minutes: durationMins));

        // Skip past slots if today
        final isPast = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day &&
            slotStart.isBefore(now.add(const Duration(minutes: 30)));

        // Check overlap with booked appointments
        final isBooked = bookedSlots.any((b) =>
            slotStart.isBefore(b.end) && slotEnd.isAfter(b.start));

        final timeLabel = DateFormat('h:mm a').format(slotStart);
        final timeStr = DateFormat('HH:mm').format(slotStart);

        slots.add(TimeSlot(
          timeString: timeStr,
          displayLabel: timeLabel,
          isAvailable: !isPast && !isBooked,
          reasonUnavailable: isPast
              ? 'Past time'
              : isBooked
                  ? 'Already booked'
                  : null,
        ));

        slotStart = slotStart.add(const Duration(minutes: 30));
      }

      return slots;
    } catch (e) {
      if (kDebugMode) debugPrint('[APPOINTMENT] getAvailableSlots error: $e');
      return [];
    }
  }

  /// Computes available slots for "Any Available Barber" by aggregating slots
  /// across all active working barbers who are not on leave.
  Future<List<TimeSlot>> getAvailableSlotsForAnyBarber({
    required List<Barber> barbers,
    required String serviceId,
    required DateTime date,
  }) async {
    if (barbers.isEmpty) return [];

    final activeBarbers = barbers.where((b) => b.isActive).toList();
    if (activeBarbers.isEmpty) return [];

    // Fetch slots for each active barber concurrently
    final List<List<TimeSlot>> barberSlotsList = await Future.wait<List<TimeSlot>>(
      activeBarbers.map((b) => getAvailableSlots(
        barberId: b.id,
        serviceId: serviceId,
        date: date,
      )),
    );

    // Find the first slots list with slots as template
    final templateSlots = barberSlotsList.firstWhere(
      (slots) => slots.isNotEmpty,
      orElse: () => [],
    );

    if (templateSlots.isEmpty) return [];

    final aggregatedSlots = <TimeSlot>[];

    for (int i = 0; i < templateSlots.length; i++) {
      final template = templateSlots[i];
      bool isAnyAvailable = false;
      String? unavailableReason = template.reasonUnavailable;

      for (final barberSlots in barberSlotsList) {
        if (i < barberSlots.length) {
          final slot = barberSlots[i];
          if (slot.isAvailable) {
            isAnyAvailable = true;
            unavailableReason = null;
            break;
          }
        }
      }

      aggregatedSlots.add(TimeSlot(
        timeString: template.timeString,
        displayLabel: template.displayLabel,
        isAvailable: isAnyAvailable,
        reasonUnavailable: unavailableReason,
      ));
    }

    return aggregatedSlots;
  }

  /// Uses the atomic PostgreSQL function to create an appointment safely
  /// (handles double-booking prevention at the database level).
  Future<Appointment> createAppointment({
    required String customerId,
    required String barberId,
    required String serviceId,
    String? hairstyleId,
    required DateTime appointmentDate,
    required String startTime,
    String? notes,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(appointmentDate);

    try {
      final result = await SupabaseService.client.rpc('create_appointment_atomic', params: {
        'p_customer_id': customerId,
        'p_barber_id': barberId,
        'p_service_id': serviceId,
        'p_hairstyle_id': hairstyleId,
        'p_appointment_date': dateStr,
        'p_start_time': startTime,
        'p_notes': notes,
      });

      if (result is Map<String, dynamic>) {
        if (result['success'] != true) {
          throw BookingException(result['error']?.toString() ?? 'Booking failed.');
        }

        final appointmentId = result['appointment_id'] as String;

        // Fetch the full appointment row
        final apptRes = await SupabaseService.client
            .from('appointments')
            .select('*, barbers(profiles(full_name, avatar_url)), services(name, image_url)')
            .eq('id', appointmentId)
            .single();

        return Appointment.fromJson(apptRes);
      }

      throw BookingException('Unexpected response from booking service.');
    } on BookingException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[APPOINTMENT] createAppointment error: $e');
      throw BookingException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus newStatus) async {
    await SupabaseService.client
        .from('appointments')
        .update({
          'status': newStatus.name,
          'updated_at': DateTime.now().toIso8601String(),
          if (newStatus == AppointmentStatus.completed)
            'completed_at': DateTime.now().toIso8601String(),
          if (newStatus == AppointmentStatus.cancelled)
            'cancelled_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }
}
