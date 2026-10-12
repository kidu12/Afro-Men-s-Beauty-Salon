import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/media_upload_helper.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/hairstyle.dart';
import '../../data/models/hairstyle_media.dart';
import '../../data/repositories/hairstyle_repository.dart';
import '../styles/style_providers.dart';

const _uuid = Uuid();

class AdminStylesScreen extends ConsumerWidget {
  const AdminStylesScreen({super.key});

  void _showAddStyleDialog(BuildContext context, WidgetRef ref, Hairstyle? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final catCtrl = TextEditingController(text: existing?.category ?? 'Low Fade');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String imageUrl = existing?.primaryImageUrl ?? '';
    String videoUrl = (existing != null && existing.hasVideo)
        ? existing.media.firstWhere((m) => m.isVideo).mediaUrl
        : '';
    bool isFeatured = existing?.isFeatured ?? false;
    bool isTrending = existing?.isTrending ?? false;
    bool isUploadingImage = false;
    bool isUploadingVideo = false;
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
            existing == null ? 'Add Hairstyle' : 'Edit Hairstyle',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Style Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Low Drop Fade + Sponge Top')),
                const SizedBox(height: 12),

                const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: catCtrl, decoration: const InputDecoration(hintText: 'e.g. Low Fade, Afro, Dreads')),
                const SizedBox(height: 12),

                const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Style detailing...')),
                const SizedBox(height: 16),

                // ── Photo Upload ──
                const Text('Style Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Thumbnail preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _mediaPlaceholder(Icons.image_outlined, 64))
                          : _mediaPlaceholder(Icons.image_outlined, 64),
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
                              label: Text(imageUrl.isNotEmpty ? 'Change Photo' : 'Upload Photo'),
                              onPressed: () async {
                                setState(() => isUploadingImage = true);
                                try {
                                  final url = await MediaUploadHelper.pickAndUploadImage(
                                    bucket: 'hairstyles',
                                    folder: 'styles',
                                  );
                                  if (url != null) setState(() => imageUrl = url);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Photo upload failed: $e'), backgroundColor: Colors.red),
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
                const SizedBox(height: 16),

                // ── Video Upload ──
                const Text('Style Video (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Video status icon
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        videoUrl.isNotEmpty ? Icons.videocam_rounded : Icons.videocam_off_outlined,
                        color: videoUrl.isNotEmpty ? AppColors.gold : AppColors.textMuted,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isUploadingVideo
                          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceElevated,
                                    foregroundColor: AppColors.gold,
                                    side: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  icon: const Icon(Icons.video_library_outlined, size: 16),
                                  label: Text(videoUrl.isNotEmpty ? 'Change Video' : 'Upload Video'),
                                  onPressed: () async {
                                    setState(() => isUploadingVideo = true);
                                    try {
                                      final url = await MediaUploadHelper.pickAndUploadVideo(
                                        bucket: 'hairstyles',
                                        folder: 'styles',
                                      );
                                      if (url != null) setState(() => videoUrl = url);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Video upload failed: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    } finally {
                                      setState(() => isUploadingVideo = false);
                                    }
                                  },
                                ),
                                if (videoUrl.isNotEmpty)
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                    label: const Text('Remove Video', style: TextStyle(fontSize: 11, color: Colors.red)),
                                    onPressed: () => setState(() => videoUrl = ''),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                CheckboxListTile(
                  title: const Text('Mark as Featured', style: TextStyle(fontSize: 13)),
                  value: isFeatured,
                  activeColor: AppColors.gold,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => isFeatured = v ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Mark as Trending', style: TextStyle(fontSize: 13)),
                  value: isTrending,
                  activeColor: AppColors.gold,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => isTrending = v ?? false),
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
              onPressed: (isSaving || isUploadingImage || isUploadingVideo)
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      setState(() => isSaving = true);
                      try {
                        // Use the existing style UUID or generate a new one
                        final styleId = existing?.id ?? _uuid.v4();
                        final media = <HairstyleMedia>[];

                        if (imageUrl.isNotEmpty) {
                          media.add(HairstyleMedia(
                            id: _uuid.v4(),
                            hairstyleId: styleId,
                            mediaUrl: imageUrl,
                            mediaType: 'image',
                          ));
                        }
                        if (videoUrl.isNotEmpty) {
                          media.add(HairstyleMedia(
                            id: _uuid.v4(),
                            hairstyleId: styleId,
                            mediaUrl: videoUrl,
                            mediaType: 'video',
                            thumbnailUrl: imageUrl.isNotEmpty ? imageUrl : null,
                          ));
                        }

                        final updated = Hairstyle(
                          id: styleId,
                          name: name,
                          category: catCtrl.text.trim().isEmpty ? 'Classic' : catCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                          isFeatured: isFeatured,
                          isTrending: isTrending,
                          media: media.isNotEmpty
                              ? media
                              : (existing?.media ?? []),
                        );

                        await ref.read(hairstyleRepositoryProvider).saveHairstyle(updated);
                        ref.invalidate(hairstylesProvider);
                        ref.invalidate(featuredStylesProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Style saved!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        setState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save style: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                    )
                  : const Text('Save Style'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaPlaceholder(IconData icon, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.textMuted, size: size * 0.4),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stylesAsync = ref.watch(hairstylesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageStyles, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold),
            onPressed: () => _showAddStyleDialog(context, ref, null),
          ),
        ],
      ),
      body: stylesAsync.when(
        data: (styles) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: styles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = styles[index];
            return GlassCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      s.primaryImageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60, height: 60,
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(s.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (s.isFeatured)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('FEATURED', style: TextStyle(fontSize: 9, color: AppColors.gold, fontWeight: FontWeight.w800)),
                              ),
                            if (s.hasVideo)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('VIDEO', style: TextStyle(fontSize: 9, color: AppColors.info, fontWeight: FontWeight.w800)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                    onPressed: () => _showAddStyleDialog(context, ref, s),
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
