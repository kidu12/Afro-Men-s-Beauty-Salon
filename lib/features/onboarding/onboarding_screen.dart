import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/services/local_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final storage = await LocalStorageService.init();
    await storage.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go(AppConstants.homePath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final pages = [
      {
        'title': l10n.onboardingTitle1,
        'subtitle': l10n.onboardingSubtitle1,
        'image': 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&q=80',
        'tag': l10n.onboardingTag1,
      },
      {
        'title': l10n.onboardingTitle2,
        'subtitle': l10n.onboardingSubtitle2,
        'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80',
        'tag': l10n.onboardingTag2,
      },
      {
        'title': l10n.onboardingTitle3,
        'subtitle': l10n.onboardingSubtitle3,
        'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80',
        'tag': l10n.onboardingTag3,
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Page View with Hero Background
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    page['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surface),
                  ),
                  // Dark Vignette Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.3),
                          AppColors.background.withValues(alpha: 0.7),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 0.85],
                      ),
                    ),
                  ),
                  // Text Content
                  Positioned(
                    bottom: 150,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            page['tag']!,
                            style: const TextStyle(
                              color: AppColors.textInverse,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['subtitle']!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip Button Top Right
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                l10n.skip,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Bottom Indicator & CTA
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      height: 4,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.gold : AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  title: _currentPage == pages.length - 1 ? l10n.getStarted : l10n.continueBtn,
                  onPressed: () {
                    if (_currentPage < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

