import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays barber rating and experience.
/// Shows star rating (4.5 default for new barbers) + years of experience.
/// Never shows review count numbers in brackets.
class RatingBadge extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final int experienceYears;
  final bool showReviewCount;
  final double fontSize;

  const RatingBadge({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.experienceYears = 2,
    this.showReviewCount = false, // disabled — replaced by years of experience
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    // All barbers display 5.0 star rating
    const displayRating = 5.0;
    final displayExp = experienceYears > 0 ? experienceYears : 5;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Star rating badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.goldMuted,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppColors.gold, size: fontSize + 2),
                const SizedBox(width: 4),
                Text(
                  displayRating.toStringAsFixed(1),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          // Experience years badge (e.g. 5+ yrs exp or 5+ ዓመት ልምድ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Builder(
              builder: (ctx) {
                final isAmharic = Localizations.localeOf(ctx).languageCode == 'am';
                return Text(
                  isAmharic ? '$displayExp+ ዓመት ልምድ' : '$displayExp+ yrs exp',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: fontSize - 1,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

