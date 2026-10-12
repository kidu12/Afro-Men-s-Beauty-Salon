import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service_item.dart';
import '../../data/models/barber.dart';
import '../../data/models/hairstyle.dart';
import '../../data/models/time_slot.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointment_repository.dart';
import '../auth/auth_state_provider.dart';

class BookingState {
  final int currentStep; // 0 to 4
  final ServiceItem? selectedService;
  final Barber? selectedBarber;
  final bool isAnyBarber;
  final Hairstyle? selectedHairstyle;
  final DateTime selectedDate;
  final TimeSlot? selectedTimeSlot;
  final String? notes;
  final bool isLoading;
  final String? errorMessage;
  final Appointment? confirmedAppointment;

  BookingState({
    this.currentStep = 0,
    this.selectedService,
    this.selectedBarber,
    this.isAnyBarber = false,
    this.selectedHairstyle,
    DateTime? selectedDate,
    this.selectedTimeSlot,
    this.notes,
    this.isLoading = false,
    this.errorMessage,
    this.confirmedAppointment,
  }) : selectedDate = selectedDate ?? DateTime.now().add(const Duration(days: 1));

  bool get canProceedToStep1 => selectedService != null && selectedService!.isBookingConfigured;
  bool get canProceedToStep2 => selectedBarber != null || isAnyBarber;
  bool get canProceedToStep3 => true;
  bool get canProceedToStep4 => selectedTimeSlot != null && selectedTimeSlot!.isAvailable;

  BookingState copyWith({
    int? currentStep,
    ServiceItem? selectedService,
    Barber? selectedBarber,
    bool? isAnyBarber,
    Hairstyle? selectedHairstyle,
    DateTime? selectedDate,
    TimeSlot? selectedTimeSlot,
    String? notes,
    bool? isLoading,
    String? errorMessage,
    Appointment? confirmedAppointment,
    bool clearBarber = false,
    bool clearTimeSlot = false,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedService: selectedService ?? this.selectedService,
      selectedBarber: clearBarber ? null : (selectedBarber ?? this.selectedBarber),
      isAnyBarber: isAnyBarber ?? this.isAnyBarber,
      selectedHairstyle: selectedHairstyle ?? this.selectedHairstyle,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: clearTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      confirmedAppointment: confirmedAppointment ?? this.confirmedAppointment,
    );
  }
}

final bookingStateProvider = StateNotifierProvider.autoDispose<BookingNotifier, BookingState>((ref) {
  final aptRepo = ref.watch(appointmentRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  return BookingNotifier(aptRepo, authState.value?.id ?? '55555555-5555-5555-5555-555555555555');
});

class BookingNotifier extends StateNotifier<BookingState> {
  final AppointmentRepository _aptRepo;
  final String _currentUserId;

  BookingNotifier(this._aptRepo, this._currentUserId) : super(BookingState());

  void preselectStyle(Hairstyle style, ServiceItem? recommendedService) {
    state = state.copyWith(
      selectedHairstyle: style,
      selectedService: recommendedService,
      currentStep: recommendedService != null ? 1 : 0,
    );
  }

  void selectService(ServiceItem service) {
    state = state.copyWith(
      selectedService: service,
      clearTimeSlot: true,
      currentStep: 1,
    );
  }

  void selectBarber(Barber? barber, {bool isAny = false}) {
    state = state.copyWith(
      selectedBarber: barber,
      isAnyBarber: isAny,
      clearTimeSlot: true,
      currentStep: 2,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      clearTimeSlot: true,
      currentStep: 3,
    );
  }

  void selectTimeSlot(TimeSlot slot) {
    state = state.copyWith(
      selectedTimeSlot: slot,
      currentStep: 4,
    );
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<List<TimeSlot>> loadAvailableSlots(
    String barberId,
    String serviceId,
    DateTime date, {
    List<Barber>? allBarbers,
    bool isAny = false,
  }) async {
    if (isAny && allBarbers != null && allBarbers.isNotEmpty) {
      return _aptRepo.getAvailableSlotsForAnyBarber(
        barbers: allBarbers,
        serviceId: serviceId,
        date: date,
      );
    }
    return _aptRepo.getAvailableSlots(
      barberId: barberId,
      serviceId: serviceId,
      date: date,
    );
  }

  Future<bool> confirmAppointment({String? defaultBarberId}) async {
    if (state.selectedService == null ||
        (state.selectedBarber == null && !state.isAnyBarber) ||
        state.selectedTimeSlot == null) {
      state = state.copyWith(errorMessage: 'Please complete all booking steps.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final barberId = state.selectedBarber?.id ?? defaultBarberId ?? 'c0000000-0000-0000-0000-000000000001';
      final appointment = await _aptRepo.createAppointment(
        customerId: _currentUserId,
        barberId: barberId,
        serviceId: state.selectedService!.id,
        hairstyleId: state.selectedHairstyle?.id,
        appointmentDate: state.selectedDate,
        startTime: state.selectedTimeSlot!.timeString,
        notes: state.notes,
      );

      state = state.copyWith(
        isLoading: false,
        confirmedAppointment: appointment,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = BookingState();
  }
}
