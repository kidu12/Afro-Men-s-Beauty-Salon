import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/notification_repository.dart';
import '../auth/auth_state_provider.dart';

final notificationsProvider = FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.id ?? '55555555-5555-5555-5555-555555555555';
  return repo.getNotifications(userId);
});

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final asyncNotifs = ref.watch(notificationsProvider);
  return asyncNotifs.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
