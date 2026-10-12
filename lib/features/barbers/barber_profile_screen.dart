import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/utils/formatters.dart';
import '../booking/booking_state_provider.dart';
import 'barber_providers.dart';

class BarberProfileScreen extends ConsumerWidget {
  final String barberId;

  const BarberProfileScreen({super.key, required this.barberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final barberAsync = ref.watch(barberDetailProvider(barberId));
    final reviewsAsync = ref.watch(barberReviewsProvider(barberId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.barberDetails, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: barberAsync.when(
        data: (barber) {
          if (barber == null) {
            return Center(child: Text(l10n.barberDetails));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile Card
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: barber.avatarUrl != null ? NetworkImage(barber.avatarUrl!) : null,
                        backgroundColor: AppColors.surfaceElevated,
                        child: barber.avatarUrl == null ? const Icon(Icons.person, color: AppColors.gold, size: 40) : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        barber.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${barber.experienceYears}+ ${l10n.yearsExperience}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      RatingBadge(
                        rating: barber.ratingAvg,
                        totalReviews: barber.totalReviews,
                        experienceYears: barber.experienceYears,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Bio
                if (barber.bio != null) ...[
                  Text(l10n.aboutSection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    barber.bio!,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                ],

                // Portfolio Photos
                if (barber.portfolioUrls.isNotEmpty) ...[
                  Text(l10n.recentPortfolio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: barber.portfolioUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            barber.portfolioUrls[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Reviews Section
                Text(l10n.customerReviews, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                reviewsAsync.when(
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return GlassCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              l10n.noReviewsYet,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: reviews.map((r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r.customerName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: i < r.rating ? AppColors.gold : AppColors.surfaceBorder,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (r.comment != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    r.comment!,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  Formatters.formatShortDate(r.createdAt, l10n.isAmharic),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // CTA: BOOK WITH THIS BARBER
                PrimaryButton(
                  title: '${l10n.bookWith} ${barber.name.toUpperCase()}',
                  icon: Icons.calendar_month_rounded,
                  onPressed: () {
                    ref.read(bookingStateProvider.notifier).selectBarber(barber);
                    context.push(AppConstants.bookingPath);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
