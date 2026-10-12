import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/rating_badge.dart';
import '../../data/models/barber.dart';
import '../../data/repositories/barber_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../../data/services/supabase_service.dart';
import '../barbers/barber_providers.dart';


class AdminBarbersScreen extends ConsumerWidget {
  const AdminBarbersScreen({super.key});

  void _showAddBarberDialog(BuildContext context, WidgetRef ref, Barber? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final bioCtrl = TextEditingController(text: existing?.bio ?? '');
    final expCtrl = TextEditingController(text: existing != null ? '${existing.experienceYears}+' : '5+');
    String avatarUrl = existing?.avatarUrl ?? '';
    bool isActive = existing?.isActive ?? true;
    bool isUploading = false;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.surfaceBorder),
            ),
            title: Text(existing == null ? 'Add Master Barber' : 'Edit Barber', style: const TextStyle(fontWeight: FontWeight.w800)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Mike Tadesse')),
                  const SizedBox(height: 12),

                  const Text('Experience (Years)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: expCtrl, keyboardType: TextInputType.text, decoration: const InputDecoration(hintText: 'e.g. 5+, 12+')),
                  const SizedBox(height: 12),

                  const Text('Bio / Specialties', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: bioCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Master fade architect...')),
                  const SizedBox(height: 12),

                  const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    title: const Text('Active Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Controls if the barber is visible for customer booking', style: TextStyle(fontSize: 11)),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.gold,
                    value: isActive,
                    onChanged: (val) {
                      setState(() => isActive = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  const Text('Barber Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        backgroundColor: AppColors.surfaceElevated,
                        child: avatarUrl.isEmpty ? const Icon(Icons.person, color: AppColors.gold) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: isUploading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceElevated,
                                  foregroundColor: AppColors.gold,
                                  side: const BorderSide(color: AppColors.surfaceBorder),
                                ),
                                icon: const Icon(Icons.photo_library_outlined, size: 16),
                                label: const Text('Select Photo'),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (image != null) {
                                    setState(() => isUploading = true);
                                    try {
                                      final file = File(image.path);
                                      final fileName =
                                          'barbers/${DateTime.now().millisecondsSinceEpoch}.jpg';
                                      await SupabaseService.client.storage
                                          .from('avatars')
                                          .upload(fileName, file,
                                              fileOptions: FileOptions(
                                                  contentType: 'image/jpeg',
                                                  upsert: true));
                                      final publicUrl = SupabaseService.client.storage
                                          .from('avatars')
                                          .getPublicUrl(fileName);
                                      setState(() {
                                        avatarUrl = publicUrl;
                                        isUploading = false;
                                      });
                                    } catch (e) {
                                      setState(() => isUploading = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to upload image: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textInverse),
                onPressed: (isSaving || isUploading)
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;

                        setState(() => isSaving = true);

                        try {
                          final expRaw = expCtrl.text.trim();
                          final digitsOnly = expRaw.replaceAll(RegExp(r'[^0-9]'), '');
                          final experienceYears = int.tryParse(digitsOnly) ?? int.tryParse(expRaw) ?? 0;

                          final updated = Barber(
                            id: existing?.id ?? '',
                            profileId: existing?.profileId ?? '',
                            name: name,
                            bio: bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
                            experienceYears: experienceYears,
                            ratingAvg: existing?.ratingAvg ?? 5.0,
                            totalReviews: existing?.totalReviews ?? 0,
                            avatarUrl: avatarUrl.isNotEmpty
                                ? avatarUrl
                                : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
                            isActive: isActive,
                          );

                          await ref.read(barberRepositoryProvider).saveBarber(updated);
                          ref.invalidate(barbersProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barber saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save barber: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                      )
                    : const Text('Save Barber'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManageLeavesDialog(BuildContext context, WidgetRef ref, Barber barber) {
    final reasonCtrl = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final repo = ref.read(barberRepositoryProvider);

          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.surfaceBorder),
            ),
            title: Text('Manage Leaves: ${barber.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: double.maxFinite,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: repo.getBarberDaysOff(barber.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    );
                  }

                  final leaves = snapshot.data ?? [];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Schedule Leave Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.surfaceBorder),
                                foregroundColor: AppColors.textPrimary,
                              ),
                              icon: const Icon(Icons.calendar_month_outlined, size: 16),
                              label: Text(
                                selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('yyyy-MM-dd').format(selectedDate!),
                              ),
                              onPressed: () async {
                                final now = DateTime.now();
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now.subtract(const Duration(days: 30)),
                                  lastDate: now.add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => selectedDate = date);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reasonCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Reason (e.g. Sick Leave, Holiday)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.textInverse,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Leave'),
                          onPressed: () async {
                            if (selectedDate == null) return;
                            final reason = reasonCtrl.text.trim();
                            await repo.addBarberDayOff(
                              barber.id,
                              selectedDate!,
                              reason.isEmpty ? 'Scheduled Leave' : reason,
                            );
                            reasonCtrl.clear();
                            selectedDate = null;
                            setState(() {}); 
                          },
                        ),
                      ),
                      const Divider(height: 24),
                      const Text('Scheduled Days Off / Leaves', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      if (leaves.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('No leaves scheduled.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: leaves.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final leave = leaves[i];
                              final date = leave['off_date'] as String;
                              final reason = leave['reason'] as String? ?? 'Scheduled Leave';
                              final id = leave['id'] as String;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                subtitle: Text(reason, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  onPressed: () async {
                                    await repo.deleteBarberDayOff(barber.id, id);
                                    setState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final barbersAsync = ref.watch(barbersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageBarbers, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.gold),
            onPressed: () => _showAddBarberDialog(context, ref, null),
          ),
        ],
      ),
      body: barbersAsync.when(
        data: (barbers) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: barbers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final b = barbers[index];
            return GlassCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: b.avatarUrl != null ? NetworkImage(b.avatarUrl!) : null,
                    backgroundColor: AppColors.surfaceElevated,
                    child: b.avatarUrl == null ? const Icon(Icons.person, color: AppColors.gold) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(b.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            if (!b.isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                ),
                                child: const Text('INACTIVE', style: TextStyle(color: AppColors.error, fontSize: 8, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${b.experienceYears}+ ${l10n.yearsExperience}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        RatingBadge(
                          rating: b.ratingAvg,
                          totalReviews: b.totalReviews,
                          experienceYears: b.experienceYears,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined, color: AppColors.gold, size: 20),
                    tooltip: 'Manage Leaves',
                    onPressed: () => _showManageLeavesDialog(context, ref, b),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                    onPressed: () => _showAddBarberDialog(context, ref, b),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
