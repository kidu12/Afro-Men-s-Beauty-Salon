enum AppointmentStatus {
  pending,
  confirmed,
  checked_in,
  in_progress,
  completed,
  cancelled,
  no_show;

  static AppointmentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'checked_in':
        return AppointmentStatus.checked_in;
      case 'in_progress':
        return AppointmentStatus.in_progress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.no_show;
      case 'confirmed':
      default:
        return AppointmentStatus.confirmed;
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.checked_in:
        return 'Checked In';
      case AppointmentStatus.in_progress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.no_show:
        return 'No Show';
    }
  }

  String localizedName(dynamic l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case AppointmentStatus.pending:
        return l10n.statusPending as String;
      case AppointmentStatus.confirmed:
        return l10n.statusConfirmed as String;
      case AppointmentStatus.checked_in:
        return l10n.statusCheckedIn as String;
      case AppointmentStatus.in_progress:
        return l10n.statusInProgress as String;
      case AppointmentStatus.completed:
        return l10n.statusCompleted as String;
      case AppointmentStatus.cancelled:
        return l10n.statusCancelled as String;
      case AppointmentStatus.no_show:
        return l10n.statusNoShow as String;
    }
  }

  /// Returns the valid next statuses an admin can transition this appointment to.
  List<AppointmentStatus> get allowedTransitions {
    switch (this) {
      case AppointmentStatus.pending:
        return [AppointmentStatus.confirmed, AppointmentStatus.cancelled];
      case AppointmentStatus.confirmed:
        return [AppointmentStatus.checked_in, AppointmentStatus.in_progress, AppointmentStatus.completed, AppointmentStatus.cancelled, AppointmentStatus.no_show];
      case AppointmentStatus.checked_in:
        return [AppointmentStatus.in_progress, AppointmentStatus.cancelled];
      case AppointmentStatus.in_progress:
        return [AppointmentStatus.completed, AppointmentStatus.cancelled];
      case AppointmentStatus.completed:
      case AppointmentStatus.cancelled:
      case AppointmentStatus.no_show:
        return []; // Terminal
    }
  }
}

class Appointment {
  final String id;
  final String appointmentReference; // e.g. "AFB-20260821-0047"
  final String? branchId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerAvatar;
  final String barberId;
  final String barberName;
  final String? barberAvatar;
  final String serviceId;
  final String serviceName;
  final String? hairstyleId;
  final String? hairstyleName;
  final DateTime appointmentDate;
  final String startTime; // "09:00:00"
  final String endTime; // "09:45:00"
  final AppointmentStatus status;
  final num? priceSnapshot; // Nullable!
  final int? durationSnapshot; // Duration in minutes
  final String serviceNameSnapshot;
  final String? notes;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  const Appointment({
    required this.id,
    required this.appointmentReference,
    this.branchId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerAvatar,
    required this.barberId,
    required this.barberName,
    this.barberAvatar,
    required this.serviceId,
    required this.serviceName,
    this.hairstyleId,
    this.hairstyleName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.status = AppointmentStatus.confirmed,
    this.priceSnapshot,
    this.durationSnapshot,
    required this.serviceNameSnapshot,
    this.notes,
    required this.createdAt,
    this.cancelledAt,
    this.completedAt,
  });

  bool get isUpcoming =>
      (status == AppointmentStatus.confirmed ||
          status == AppointmentStatus.pending ||
          status == AppointmentStatus.checked_in ||
          status == AppointmentStatus.in_progress) &&
      appointmentDate.isAfter(DateTime.now().subtract(const Duration(days: 1)));

  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get canCancelOrReschedule =>
      (status == AppointmentStatus.confirmed || status == AppointmentStatus.pending);

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final customerObj = json['customer'] as Map<String, dynamic>?;
    final barberObj = json['barber'] as Map<String, dynamic>?;
    final serviceObj = json['service'] as Map<String, dynamic>?;
    final hairstyleObj = json['hairstyle'] as Map<String, dynamic>?;

    final ref = json['appointment_reference'] as String? ??
        'AFB-${(json['appointment_date'] as String? ?? '20260821').replaceAll('-', '')}-${json['id'].toString().substring(0, 4).toUpperCase()}';

    return Appointment(
      id: json['id'] as String,
      appointmentReference: ref,
      branchId: json['branch_id'] as String?,
      customerId: json['customer_id'] as String,
      customerName: customerObj != null
          ? (customerObj['full_name'] as String? ?? 'Customer')
          : (json['customer_name'] as String? ?? 'Customer'),
      customerPhone: customerObj != null ? customerObj['phone'] as String? : json['customer_phone'] as String?,
      customerAvatar: customerObj != null ? customerObj['avatar_url'] as String? : json['customer_avatar'] as String?,
      barberId: json['barber_id'] as String,
      barberName: barberObj != null
          ? (barberObj['name'] as String? ?? 'Barber')
          : (json['barber_name'] as String? ?? 'Barber'),
      barberAvatar: barberObj != null ? barberObj['avatar_url'] as String? : json['barber_avatar'] as String?,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name_snapshot'] as String? ??
          (serviceObj != null ? (serviceObj['name'] as String? ?? 'Service') : 'Service'),
      hairstyleId: json['hairstyle_id'] as String?,
      hairstyleName: hairstyleObj != null ? hairstyleObj['name'] as String? : json['hairstyle_name'] as String?,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: AppointmentStatus.fromString(json['status'] as String?),
      priceSnapshot: json['price_snapshot'] != null ? (json['price_snapshot'] as num) : null,
      durationSnapshot: json['duration_snapshot'] as int?,
      serviceNameSnapshot: json['service_name_snapshot'] as String? ?? 'Service',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_reference': appointmentReference,
      'branch_id': branchId,
      'customer_id': customerId,
      'barber_id': barberId,
      'service_id': serviceId,
      'hairstyle_id': hairstyleId,
      'appointment_date': appointmentDate.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'status': status.name,
      'price_snapshot': priceSnapshot,
      'duration_snapshot': durationSnapshot,
      'service_name_snapshot': serviceNameSnapshot,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    DateTime? cancelledAt,
    DateTime? completedAt,
  }) {
    return Appointment(
      id: id,
      appointmentReference: appointmentReference,
      branchId: branchId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAvatar: customerAvatar,
      barberId: barberId,
      barberName: barberName,
      barberAvatar: barberAvatar,
      serviceId: serviceId,
      serviceName: serviceName,
      hairstyleId: hairstyleId,
      hairstyleName: hairstyleName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      priceSnapshot: priceSnapshot,
      durationSnapshot: durationSnapshot,
      serviceNameSnapshot: serviceNameSnapshot,
      notes: notes,
      createdAt: createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
