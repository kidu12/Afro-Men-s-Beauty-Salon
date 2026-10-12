import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../data/repositories/barber_repository.dart';
import '../../data/repositories/hairstyle_repository.dart';
import '../booking/booking_state_provider.dart';
import '../reviews/leave_review_dialog.dart';
import 'appointment_providers.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelAppointment(Appointment apt) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color ?? AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.surfaceBorder)),
        title: Text(l10n.cancelAppointment, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          l10n.cancelConfirmMsg,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.keepAppointment, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yesCancel),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(appointmentRepositoryProvider).updateAppointmentStatus(apt.id, AppointmentStatus.cancelled);
      ref.invalidate(customerAppointmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.statusCancelled)),
      );
    }
  }

  Future<void> _rebookAppointment(Appointment apt) async {
    final services = await ref.read(serviceRepositoryProvider).getServices();
    final service = services.firstWhere(
      (s) => s.id == apt.serviceId,
      orElse: () => services.first,
    );

    final barbers = await ref.read(barberRepositoryProvider).getBarbers();
    final barber = barbers.firstWhere(
      (b) => b.id == apt.barberId,
      orElse: () => barbers.first,
    );

    dynamic hairstyle;
    if (apt.hairstyleId != null) {
      final styles = await ref.read(hairstyleRepositoryProvider).getHairstyles();
      hairstyle = styles.firstWhere((h) => h.id == apt.hairstyleId, orElse: () => styles.first);
    }

    ref.read(bookingStateProvider.notifier).preselectStyle(hairstyle, service);
    ref.read(bookingStateProvider.notifier).selectBarber(barber);
    ref.read(bookingStateProvider.notifier).goToStep(2);

    if (!mounted) return;
    context.push(AppConstants.bookingPath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appointmentsAsync = ref.watch(customerAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAppointmentsTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: l10n.tabUpcoming.toUpperCase()),
            Tab(text: l10n.tabPast.toUpperCase()),
          ],
        ),
      ),
      body: appointmentsAsync.when(
        data: (allAppointments) {
          final upcoming = allAppointments.where((a) => a.isUpcoming).toList();
          final past = allAppointments.where((a) => !a.isUpcoming).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentsList(upcoming, isUpcoming: true),
              _buildAppointmentsList(past, isUpcoming: false),
            ],
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const LoadingShimmer(width: double.infinity, height: 160),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> list, {required bool isUpcoming}) {
    final l10n = context.l10n;
    if (list.isEmpty) {
      return EmptyStateView(
        icon: isUpcoming ? Icons.calendar_today_outlined : Icons.history_rounded,
        title: isUpcoming ? l10n.noUpcomingAppts : l10n.noPastAppts,
        description: isUpcoming ? l10n.noUpcomingDesc : l10n.noPastDesc,
        actionTitle: isUpcoming ? l10n.bookNow.toUpperCase() : null,
        onAction: isUpcoming ? () => context.push(AppConstants.bookingPath) : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final apt = list[index];
        return _buildAppointmentCard(apt, isUpcoming);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment apt, bool isUpcoming) {
    final l10n = context.l10n;
    Color statusColor = AppColors.success;
    if (apt.status == AppointmentStatus.cancelled) statusColor = AppColors.error;
    if (apt.status == AppointmentStatus.in_progress) statusColor = AppColors.warning;
    if (apt.status == AppointmentStatus.completed) statusColor = AppColors.info;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Service + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: apt.barberAvatar != null ? NetworkImage(apt.barberAvatar!) : null,
                backgroundColor: AppColors.surfaceElevated,
                child: apt.barberAvatar == null ? const Icon(Icons.person, color: AppColors.gold) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          l10n.localizeServiceName(apt.serviceNameSnapshot),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Text(
                            apt.appointmentReference,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.selectedBarber}: ${apt.barberName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (apt.hairstyleName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.styleLabel}: ${apt.hairstyleName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apt.status.localizedName(l10n).toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Date & Time Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.formatDate(apt.appointmentDate, l10n.isAmharic),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    apt.startTime.substring(0, 5),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (apt.serviceName.toLowerCase().contains('home'))
                PriceTag(price: apt.priceSnapshot, isBadge: true),
            ],
          ),

          // Action Buttons
          const SizedBox(height: 14),
          if (isUpcoming && apt.canCancelOrReschedule) ...[
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    title: l10n.cancel.toUpperCase(),
                    height: 40,
                    textColor: AppColors.error,
                    borderColor: AppColors.error.withValues(alpha: 0.4),
                    onPressed: () => _cancelAppointment(apt),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    title: l10n.bookAgain.toUpperCase(),
                    height: 40,
                    onPressed: () => _rebookAppointment(apt),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                if (apt.status == AppointmentStatus.completed) ...[
                  Expanded(
                    child: SecondaryButton(
                      title: l10n.leaveReview.toUpperCase(),
                      height: 40,
                      icon: Icons.star_border_rounded,
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => LeaveReviewDialog(appointment: apt),
                        );
                        ref.invalidate(customerAppointmentsProvider);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: PrimaryButton(
                    title: l10n.bookAgain.toUpperCase(),
                    height: 40,
                    icon: Icons.replay_rounded,
                    onPressed: () => _rebookAppointment(apt),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
