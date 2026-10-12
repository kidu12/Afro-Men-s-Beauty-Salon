import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/media_upload_helper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_tag.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/service_repository.dart';
import '../services/service_providers.dart';

const _uuid = Uuid();

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  void _showEditServiceDialog(BuildContext context, WidgetRef ref, ServiceItem? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final durationCtrl = TextEditingController(text: existing?.durationMinutes?.toString() ?? '45');
    final priceCtrl = TextEditingController(text: existing?.price?.toString() ?? '');
    String imageUrl = existing?.imageUrl ?? '';
    bool isUploadingImage = false;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: Text(
            existing == null ? 'Add New Service' : 'Edit Service',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Service Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Signature Haircut'),
                ),
                const SizedBox(height: 12),

                const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Detailed description...'),
                ),
                const SizedBox(height: 12),

                const Text('Duration (Minutes)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '45'),
                ),
                const SizedBox(height: 12),

                // Price — optional, only applies to Home-to-Home type
                const Text(
                  'Price (Optional — leave empty if undecided)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 350 (Leave blank for no price)',
                    prefixIcon: Icon(Icons.money, color: AppColors.gold, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Service Image Upload ──
                const Text('Service Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl, width: 64, height: 64, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(64),
                            )
                          : _placeholder(64),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isUploadingImage
                          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceElevated,
                                foregroundColor: AppColors.gold,
                                side: const BorderSide(color: AppColors.surfaceBorder),
                              ),
                              icon: const Icon(Icons.photo_library_outlined, size: 16),
                              label: Text(imageUrl.isNotEmpty ? 'Change Image' : 'Upload Image'),
                              onPressed: () async {
                                setState(() => isUploadingImage = true);
                                try {
                                  final url = await MediaUploadHelper.pickAndUploadImage(
                                    bucket: 'services',
                                    folder: 'service-images',
                                  );
                                  if (url != null) setState(() => imageUrl = url);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                } finally {
                                  setState(() => isUploadingImage = false);
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.textInverse,
              ),
              onPressed: (isSaving || isUploadingImage)
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      setState(() => isSaving = true);
                      try {
                        final duration = int.tryParse(durationCtrl.text.trim());
                        final price = priceCtrl.text.trim().isNotEmpty
                            ? num.tryParse(priceCtrl.text.trim())
                            : null;

                        final updatedService = ServiceItem(
                          id: existing?.id ?? _uuid.v4(),
                          name: name,
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                          durationMinutes: duration,
                          price: price,
                          imageUrl: imageUrl.isNotEmpty
                              ? imageUrl
                              : 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80',
                          isActive: existing?.isActive ?? true,
                        );

                        await ref.read(serviceRepositoryProvider).saveService(updatedService);
                        ref.invalidate(servicesProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Service saved!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        setState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                    )
                  : const Text('Save Service'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: size * 0.4),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageServices, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.gold, size: 26),
            onPressed: () => _showEditServiceDialog(context, ref, null),
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (services) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = services[index];
            return GlassCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      s.imageUrl ?? '',
                      width: 54, height: 54, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 54, height: 54,
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.image_outlined, color: AppColors.textMuted, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (s.durationMinutes != null) ...[
                              Text(
                                Formatters.formatDuration(s.durationMinutes) ?? '',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (s.shouldShowPrice)
                              PriceTag(price: s.price, isBadge: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                    onPressed: () => _showEditServiceDialog(context, ref, s),
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
