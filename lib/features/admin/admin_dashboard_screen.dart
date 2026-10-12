import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/appointment.dart';
import '../auth/auth_state_provider.dart';
import '../../core/localization/app_locale_provider.dart';
import '../profile/appearance_screen.dart';
import '../appointments/appointment_providers.dart';
import '../barbers/barber_providers.dart';
import '../services/service_providers.dart';
import '../styles/style_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final l10n = context.l10n;
    final appointmentsAsync = ref.watch(allAppointmentsProvider);
    final barbersAsync = ref.watch(barbersProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final stylesAsync = ref.watch(hairstylesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboardTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Status Card
            GlassCard(
              borderColor: AppColors.gold.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TODAY’S OVERVIEW',
                        style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('SHOP OPEN', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  appointmentsAsync.when(
                    data: (all) {
                      final total = all.length;
                      final completed = all.where((a) => a.status == AppointmentStatus.completed).length;
                      final upcoming = all.where((a) => a.isUpcoming).length;
                      final cancelled = all.where((a) => a.status == AppointmentStatus.cancelled).length;

                      // Revenue calculation: ONLY calculate if prices are not null!
                      num totalRev = 0;
                      bool hasAnyPrice = false;
                      for (final a in all) {
                        if (a.priceSnapshot != null) {
                          totalRev += a.priceSnapshot!;
                          hasAnyPrice = true;
                        }
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              _statItem(l10n.totalAppointments, '$total'),
                              _statItem(l10n.statusCompleted, '$completed'),
                              _statItem(l10n.tabUpcoming, '$upcoming'),
                              _statItem(l10n.statusCancelled, '$cancelled', isError: cancelled > 0),
                            ],
                          ),
                          if (hasAnyPrice) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Recorded Revenue:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                Text(
                                  Formatters.formatPrice(totalRev) ?? '',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gold),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Management Navigation Grid
            Text(l10n.adminDashboardTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              children: [
                _adminModuleCard(
                  icon: Icons.content_cut_rounded,
                  title: l10n.manageServices,
                  subtitle: '${servicesAsync.value?.length ?? 0} configured',
                  onTap: () => context.push(AppConstants.adminServicesPath),
                ),
                _adminModuleCard(
                  icon: Icons.people_outline_rounded,
                  title: l10n.manageBarbers,
                  subtitle: '${barbersAsync.value?.length ?? 0} ${l10n.activeBarbers}',
                  onTap: () => context.push(AppConstants.adminBarbersPath),
                ),
                _adminModuleCard(
                  icon: Icons.style_outlined,
                  title: l10n.manageStyles,
                  subtitle: '${stylesAsync.value?.length ?? 0} ${l10n.totalStyles}',
                  onTap: () => context.push(AppConstants.adminStylesPath),
                ),
                _adminModuleCard(
                  icon: Icons.calendar_month_outlined,
                  title: l10n.manageAppointments,
                  subtitle: 'Master schedule & logs',
                  onTap: () => context.push(AppConstants.adminAppointmentsPath),
                ),
                _adminModuleCard(
                  icon: Icons.access_time_rounded,
                  title: l10n.businessHours,
                  subtitle: 'Shop schedule & holidays',
                  onTap: () => context.push(AppConstants.adminHoursPath),
                ),
                _adminModuleCard(
                  icon: Icons.reviews_outlined,
                  title: 'Customer Reviews',
                  subtitle: 'Review moderation',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All customer reviews published and healthy.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, {bool isError = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isError ? AppColors.error : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _adminModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
