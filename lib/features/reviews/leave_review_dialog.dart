import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/review_repository.dart';

class LeaveReviewDialog extends ConsumerStatefulWidget {
  final Appointment appointment;

  const LeaveReviewDialog({super.key, required this.appointment});

  @override
  ConsumerState<LeaveReviewDialog> createState() => _LeaveReviewDialogState();
}

class _LeaveReviewDialogState extends ConsumerState<LeaveReviewDialog> {
  int _selectedRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(reviewRepositoryProvider).submitReview(
            appointmentId: widget.appointment.id,
            customerId: widget.appointment.customerId,
            barberId: widget.appointment.barberId,
            rating: _selectedRating,
            comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.thankYouRating)),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.howWasExperience,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.rateAppointmentWith} ${widget.appointment.barberName}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Star Rating Picker
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      Icons.star_rounded,
                      color: starNum <= _selectedRating ? AppColors.gold : AppColors.surfaceHighlight,
                    ),
                    onPressed: () => setState(() => _selectedRating = starNum),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Comment text
            Text(l10n.feedbackOptional, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.writeReviewHint,
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              title: l10n.submitReview,
              isLoading: _isSubmitting,
              onPressed: _submitReview,
            ),
          ],
        ),
      ),
    );
  }
}
