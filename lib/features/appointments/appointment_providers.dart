import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointment_repository.dart';
import '../auth/auth_state_provider.dart';

final customerAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.id ?? '55555555-5555-5555-5555-555555555555';
  return repo.getAppointments(customerId: userId);
});

final barberAppointmentsProvider = FutureProvider.family.autoDispose<List<Appointment>, String>((ref, barberId) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.getAppointments(barberId: barberId);
});

final allAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.getAppointments();
});
