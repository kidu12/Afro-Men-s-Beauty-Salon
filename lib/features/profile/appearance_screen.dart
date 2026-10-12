import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme_provider.dart';
import '../../core/widgets/glass_card.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final activeTheme = ref.watch(themeProvider);

    final themeOptions = [
      _ThemeOption(
        mode: AppThemeMode.luxuryGold,
        title: l10n.themeLuxuryGold,
        description: l10n.themeLuxuryGoldDesc,
        accentColor: const Color(0xFFD4AF37),
        bgColor: const Color(0xFF0D0D0F),
        surfaceColor: const Color(0xFF1E2026),
      ),
      _ThemeOption(
        mode: AppThemeMode.ethiopianHeritage,
        title: l10n.themeEthiopianHeritage,
        description: l10n.themeEthiopianHeritageDesc,
        accentColor: const Color(0xFFF59E0B),
        secondaryColor: const Color(0xFF10B981),
        bgColor: const Color(0xFF100C0A),
        surfaceColor: const Color(0xFF241D17),
      ),
      _ThemeOption(
        mode: AppThemeMode.modernDark,
        title: l10n.themeModernDark,
        description: l10n.themeModernDarkDesc,
        accentColor: const Color(0xFF38BDF8),
        bgColor: const Color(0xFF08090C),
        surfaceColor: const Color(0xFF181B24),
      ),
      _ThemeOption(
        mode: AppThemeMode.lightPremium,
        title: l10n.themeLightPremium,
        description: l10n.themeLightPremiumDesc,
        accentColor: const Color(0xFFB45309),
        bgColor: const Color(0xFFF8F9FA),
        surfaceColor: const Color(0xFFFFFFFF),
        isLight: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appearanceSetting,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            l10n.appearanceSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          ...themeOptions.map((opt) {
            final isSelected = activeTheme == opt.mode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(opt.mode);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: opt.accentColor, width: 2)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visual Preview Box
                      Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: opt.bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: opt.isLight
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF282A33),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: opt.surfaceColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: opt.accentColor, width: 2),
                              ),
                              child: Icon(
                                Icons.content_cut_rounded,
                                color: opt.accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 8,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: opt.isLight
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFFF5F5F7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 6,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: opt.accentColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (opt.secondaryColor != null)
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: opt.secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            const SizedBox(width: 6),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: opt.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  opt.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: opt.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ThemeOption {
  final AppThemeMode mode;
  final String title;
  final String description;
  final Color accentColor;
  final Color? secondaryColor;
  final Color bgColor;
  final Color surfaceColor;
  final bool isLight;

  _ThemeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.accentColor,
    this.secondaryColor,
    required this.bgColor,
    required this.surfaceColor,
    this.isLight = false,
  });
}
