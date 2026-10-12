import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Renders a luxury gold price badge.
/// CRITICAL REQUIREMENT: If price is null, this widget renders NOTHING (SizedBox.shrink).
/// Never displays 0 ETB or placeholder pricing.
class PriceTag extends StatelessWidget {
  final num? price;
  final TextStyle? style;
  final bool isBadge;

  const PriceTag({
    super.key,
    required this.price,
    this.style,
    this.isBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAmharic = Localizations.localeOf(context).languageCode == 'am';
    final formatted = Formatters.formatPrice(price, isAmharic ? 'ብር' : 'ETB');
    if (formatted == null) {
      return const SizedBox.shrink();
    }

    if (isBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
        ),
        child: Text(
          formatted,
          style: style ??
              const TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    }

    return Text(
      formatted,
      style: style ??
          const TextStyle(
            color: AppColors.gold,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
