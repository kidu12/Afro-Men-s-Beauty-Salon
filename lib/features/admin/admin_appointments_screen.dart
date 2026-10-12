import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_tag.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointment_repository.dart';
import '../appointments/appointment_providers.dart';

class AdminAppointmentsScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends ConsumerState<AdminAppointmentsScreen> {
  String _selectedStatusFilter = 'ALL';

  Future<void> _updateStatus(String aptId, AppointmentStatus newStatus) async {
    await ref.read(appointmentRepositoryProvider).updateAppointmentStatus(aptId, newStatus);
    ref.invalidate(allAppointmentsProvider);
    ref.invalidate(customerAppointmentsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to: ${newStatus.displayName}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildStatusDropdown(Appointment apt) {
    final transitions = apt.status.allowedTransitions;
    final Color statusColor;
    switch (apt.status) {
      case AppointmentStatus.confirmed:
        statusColor = AppColors.success;
        break;
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
        break;
      case AppointmentStatus.checked_in:
        statusColor = AppColors.info;
        break;
      case AppointmentStatus.in_progress:
        statusColor = AppColors.warning;
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.info;
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.error;
        break;
      case AppointmentStatus.no_show:
        statusColor = AppColors.textMuted;
        break;
    }

    // Terminal state — show a plain badge, no dropdown
    if (transitions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          apt.status.displayName,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
        ),
      );
    }

    // Active state — show a dropdown with only valid next statuses
    return PopupMenuButton<AppointmentStatus>(
      initialValue: apt.status,
      onSelected: (st) => _updateStatus(apt.id, st),
      itemBuilder: (ctx) => transitions.map((s) {
        return PopupMenuItem(
          value: s,
          child: Text(s.displayName),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              apt.status.displayName,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
            ),
            Icon(Icons.arrow_drop_down, size: 16, color: statusColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appointmentsAsync = ref.watch(allAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allAppointments, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: ['ALL', 'CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'].map((st) {
                final isSelected = _selectedStatusFilter == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedStatusFilter = st),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.goldLight : AppColors.surfaceBorder),
                      ),
                      child: Text(
                        st,
                        style: TextStyle(
                          color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Master Appointments List
          Expanded(
            child: appointmentsAsync.when(
              data: (all) {
                var filtered = all;
                if (_selectedStatusFilter != 'ALL') {
                  filtered = all.where((a) => a.status.name.toUpperCase() == _selectedStatusFilter).toList();
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text('No appointments match this filter.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final apt = filtered[index];
                    return GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${Formatters.formatDate(apt.appointmentDate)} • ${apt.startTime.substring(0, 5)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gold),
                              ),
                              _buildStatusDropdown(apt),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Client: ${apt.customerName} (${apt.customerPhone ?? "No phone"})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('Barber: ${apt.barberName} • Service: ${apt.serviceNameSnapshot}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          if (apt.serviceNameSnapshot.toLowerCase().contains('home'))
                            PriceTag(price: apt.priceSnapshot, isBadge: true),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
