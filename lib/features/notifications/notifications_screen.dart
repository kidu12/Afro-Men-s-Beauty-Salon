import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../data/repositories/notification_repository.dart';
import '../auth/auth_state_provider.dart';
import 'notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notificationsAsync = ref.watch(notificationsProvider);
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.id ?? '55555555-5555-5555-5555-555555555555';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllAsRead(userId);
              ref.invalidate(notificationsProvider);
            },
            child: Text(l10n.markAllAsRead, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateView(
              icon: Icons.notifications_none_rounded,
              title: l10n.noNotifications,
              description: l10n.notificationsSubtitle,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return GlassCard(
                borderColor: notif.isRead ? AppColors.surfaceBorder : AppColors.gold.withValues(alpha: 0.4),
                backgroundColor: notif.isRead ? null : AppColors.gold.withValues(alpha: 0.05),
                onTap: () async {
                  await ref.read(notificationRepositoryProvider).markAsRead(notif.id);
                  ref.invalidate(notificationsProvider);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppColors.gold, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('MMM d, hh:mm a').format(notif.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
