import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/rating_badge.dart';
import '../styles/style_providers.dart';
import '../barbers/barber_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stylesAsync = ref.watch(hairstylesProvider);
    final barbersAsync = ref.watch(barbersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myFavorites, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: l10n.savedStylesTab),
            Tab(text: l10n.favoriteBarbersTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Styles Tab
          stylesAsync.when(
            data: (styles) {
              final saved = styles.take(3).toList();
              if (saved.isEmpty) {
                return EmptyStateView(
                  icon: Icons.favorite_border_rounded,
                  title: l10n.noSavedStyles,
                  description: l10n.savedFavoritesSubtitle,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: saved.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = saved[index];
                  return GlassCard(
                    onTap: () => context.push('${AppConstants.styleDetailPath}?id=${s.id}'),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            s.primaryImageUrl ?? '',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.category.toUpperCase(), style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Text('Error: $e'),
          ),

          // Barbers Tab
          barbersAsync.when(
            data: (barbers) {
              final favoriteBarbers = barbers.take(2).toList();
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteBarbers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = favoriteBarbers[index];
                  return GlassCard(
                    onTap: () => context.push('${AppConstants.barberDetailPath}?id=${b.id}'),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: b.avatarUrl != null ? NetworkImage(b.avatarUrl!) : null,
                          child: b.avatarUrl == null ? const Icon(Icons.person, color: AppColors.gold) : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              RatingBadge(
                                rating: b.ratingAvg,
                                totalReviews: b.totalReviews,
                                experienceYears: b.experienceYears,
                                fontSize: 11,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
