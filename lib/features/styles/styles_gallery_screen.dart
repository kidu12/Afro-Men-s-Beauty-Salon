import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/empty_state_view.dart';
import 'style_providers.dart';

class StylesGalleryScreen extends ConsumerStatefulWidget {
  const StylesGalleryScreen({super.key});

  @override
  ConsumerState<StylesGalleryScreen> createState() => _StylesGalleryScreenState();
}

class _StylesGalleryScreenState extends ConsumerState<StylesGalleryScreen> {
  final List<String> _categories = [
    'All',
    'Low Fade',
    'Mid Fade',
    'Taper',
    'Afro',
    'Dreads',
    'Beard',
    'Classic',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedCategory = ref.watch(selectedStyleCategoryProvider);
    final stylesAsync = ref.watch(hairstylesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.stylesTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary),
            onPressed: () => context.push(AppConstants.favoritesPath),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = selectedCategory == cat;
                return InkWell(
                  onTap: () => ref.read(selectedStyleCategoryProvider.notifier).state = cat,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.goldLight : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Text(
                      l10n.localizeCategory(cat),
                      style: TextStyle(
                        color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Styles Grid
          Expanded(
            child: stylesAsync.when(
              data: (styles) {
                if (styles.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.style_outlined,
                    title: l10n.noStylesFound,
                    description: l10n.noStylesFoundDesc,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: styles.length,
                  itemBuilder: (context, index) {
                    final style = styles[index];
                    return _buildGalleryCard(context, style);
                  },
                );
              },
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.76,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => const LoadingShimmer(width: double.infinity, height: double.infinity),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, dynamic style) {
    final l10n = context.l10n;
    return InkWell(
      onTap: () => context.push('${AppConstants.styleDetailPath}?id=${style.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    style.primaryImageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceElevated),
                  ),
                  if (style.hasVideo)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: AppColors.gold, size: 14),
                            const SizedBox(width: 2),
                            Text(l10n.isAmharic ? 'ቪዲዮ' : 'VIDEO', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.localizeCategory(style.category).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    style.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
