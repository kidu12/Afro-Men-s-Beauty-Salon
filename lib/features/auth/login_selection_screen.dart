import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/app_locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/server_config_dialog.dart';

class LoginSelectionScreen extends ConsumerWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar with Server Settings and Language Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => showServerConfigDialog(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dns_rounded, size: 14, color: AppColors.gold),
                          SizedBox(width: 5),
                          Text(
                            'Server',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(localeProvider.notifier).toggleLanguage();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, size: 16, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text(
                            currentLocale.languageCode == 'am' ? 'English' : 'አማርኛ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Logo & Branding
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: AppColors.textInverse,
                  size: 44,
                ),
              )
                  .animate()
                  .scale(duration: 700.ms, curve: Curves.easeOutBack)
                  .then()
                  .shimmer(duration: 1200.ms),

              const SizedBox(height: 28),

              Text(
                l10n.appName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),

              const SizedBox(height: 8),

              Text(
                l10n.appTagline,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.gold,
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 12),

              Text(
                l10n.homeTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 450.ms),

              const Spacer(flex: 3),

              // Customer Login Button
              PrimaryButton(
                title: l10n.customerLogin.toUpperCase(),
                icon: Icons.person_outline_rounded,
                onPressed: () => context.push(AppConstants.customerLoginPath),
              ).animate().fadeIn(delay: 550.ms).moveY(begin: 15, end: 0),

              const SizedBox(height: 14),

              // Staff Login Button
              SecondaryButton(
                title: l10n.staffLogin.toUpperCase(),
                icon: Icons.badge_outlined,
                onPressed: () => context.push(AppConstants.staffLoginPath),
              ).animate().fadeIn(delay: 650.ms).moveY(begin: 15, end: 0),

              const SizedBox(height: 20),

              // Register Customer Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.dontHaveAccount,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppConstants.customerRegisterPath),
                    child: Text(
                      l10n.registerTitle,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 750.ms),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
