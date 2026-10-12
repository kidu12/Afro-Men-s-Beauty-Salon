import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TimeSlotChip extends StatelessWidget {
  final String timeLabel;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.timeLabel,
    required this.isSelected,
    this.isAvailable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    if (!isAvailable) {
      bg = AppColors.surfaceElevated.withValues(alpha: 0.3);
      border = AppColors.surfaceBorder.withValues(alpha: 0.4);
      textColor = AppColors.textMuted.withValues(alpha: 0.5);
    } else if (isSelected) {
      bg = AppColors.gold;
      border = AppColors.goldLight;
      textColor = AppColors.textInverse;
    } else {
      bg = AppColors.surfaceElevated;
      border = AppColors.surfaceBorder;
      textColor = AppColors.textPrimary;
    }

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          timeLabel,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            decoration: !isAvailable ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
