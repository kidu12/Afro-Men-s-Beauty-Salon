import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_tag.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointment_repository.dart';
import '../appointments/appointment_providers.dart';
import '../auth/auth_state_provider.dart';
import '../../core/localization/app_locale_provider.dart';
import '../profile/appearance_screen.dart';

class BarberDashboardScreen extends ConsumerStatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  ConsumerState<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends ConsumerState<BarberDashboardScreen> {
  final String _selectedBarberId = 'barber-mike';

  Future<void> _updateStatus(String aptId, AppointmentStatus newStatus) async {
    final l10n = context.l10n;
    await ref.read(appointmentRepositoryProvider).updateAppointmentStatus(aptId, newStatus);
    ref.invalidate(allAppointmentsProvider);
    ref.invalidate(customerAppointmentsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.statusConfirmed}: ${newStatus.localizedName(l10n)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appointmentsAsync = ref.watch(allAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.barberPortalTitle, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: AppColors.gold),
            tooltip: l10n.appearanceSetting,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.gold),
            tooltip: 'Toggle Language / ቋንቋ ቀይር',
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLanguage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: l10n.logOut,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.logOut),
                  content: Text(l10n.logOutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        l10n.logOut,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authStateProvider.notifier).signOut();
                if (!context.mounted) return;
                context.go(AppConstants.loginSelectionPath);
              }
            },
          ),
        ],
      ),
      body: appointmentsAsync.when(
        data: (allApts) {
          final barberApts = allApts.where((a) => a.barberId == _selectedBarberId).toList();
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final todayApts = barberApts.where((a) => DateFormat('yyyy-MM-dd').format(a.appointmentDate) == todayStr).toList();
          final otherApts = barberApts.where((a) => DateFormat('yyyy-MM-dd').format(a.appointmentDate) != todayStr).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barber Header Card
                GlassCard(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80'),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mike Tadesse', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('Master Barber • On Duty Today (09:00 - 19:00)', style: TextStyle(fontSize: 12, color: AppColors.gold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Today's Appointments
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.todayQueue.toUpperCase()} (${todayApts.length})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: 0.8),
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(DateTime.now()),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (todayApts.isEmpty) ...[
                  GlassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                           children: [
                             const Icon(Icons.event_available_rounded, color: AppColors.gold, size: 36),
                             const SizedBox(height: 8),
                             Text(l10n.noAppointmentsToday, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                           ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Column(
                    children: todayApts.map((apt) => _buildBarberAppointmentCard(apt, l10n)).toList(),
                  ),
                ],
                const SizedBox(height: 28),

                // Section: Upcoming & Other Appointments
                Text(
                  "UPCOMING QUEUE (${otherApts.length})",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),
                if (otherApts.isEmpty)
                  const Text('No upcoming bookings for other dates.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                else
                  Column(
                    children: otherApts.map((apt) => _buildBarberAppointmentCard(apt, l10n)).toList(),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBarberAppointmentCard(Appointment apt, AppLocalizations l10n) {
    Color statusColor = AppColors.success;
    if (apt.status == AppointmentStatus.in_progress) statusColor = AppColors.warning;
    if (apt.status == AppointmentStatus.completed) statusColor = AppColors.info;
    if (apt.status == AppointmentStatus.cancelled) statusColor = AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      '${apt.startTime.substring(0, 5)} - ${apt.endTime.substring(0, 5)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Text(
                        apt.appointmentReference,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    apt.status.localizedName(l10n).toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Client & Service Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: apt.customerAvatar != null ? NetworkImage(apt.customerAvatar!) : null,
                  backgroundColor: AppColors.surfaceElevated,
                  child: apt.customerAvatar == null ? const Icon(Icons.person, color: AppColors.textPrimary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(apt.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(apt.customerPhone ?? 'No phone provided', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (apt.serviceNameSnapshot.toLowerCase().contains('home'))
                  PriceTag(price: apt.priceSnapshot, isBadge: true),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Service: ${apt.serviceNameSnapshot} (${Formatters.formatDuration(apt.durationSnapshot) ?? '45 min'})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            if (apt.hairstyleName != null) ...[
              const SizedBox(height: 2),
              Text(
                'Style: ${apt.hairstyleName}',
                style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
              ),
            ],
            if (apt.notes != null && apt.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Client Note: "${apt.notes}"',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 14),

            // Barber Status Action Buttons
            if (apt.status != AppointmentStatus.completed && apt.status != AppointmentStatus.cancelled) ...[
              Row(
                children: [
                  if (apt.status == AppointmentStatus.confirmed)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceHighlight,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _updateStatus(apt.id, AppointmentStatus.checked_in),
                        child: const Text('CHECK IN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  if (apt.status == AppointmentStatus.checked_in || apt.status == AppointmentStatus.confirmed) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _updateStatus(apt.id, AppointmentStatus.in_progress),
                        child: Text(l10n.actionStart.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                  if (apt.status == AppointmentStatus.in_progress)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _updateStatus(apt.id, AppointmentStatus.completed),
                        child: Text(l10n.actionComplete.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.surface,
                        builder: (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_off_outlined, color: AppColors.warning),
                              title: Text(l10n.actionNoShow),
                              onTap: () {
                                Navigator.pop(ctx);
                                _updateStatus(apt.id, AppointmentStatus.no_show);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
                              title: Text(l10n.cancelAppointment),
                              onTap: () {
                                Navigator.pop(ctx);
                                _updateStatus(apt.id, AppointmentStatus.cancelled);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
