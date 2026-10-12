import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_profile.dart';
import '../auth/auth_state_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Elegant brand animation hold
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Check authoritative server authentication
    await ref.read(authStateProvider.notifier).checkAuthState();
    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    if (authState.isAuthenticated && authState.user != null) {
      final role = authState.user!.role;
      switch (role) {
        case UserRole.admin:
          context.go(AppConstants.adminDashboardPath);
          break;
        case UserRole.barber:
          context.go(AppConstants.barberDashboardPath);
          break;
        case UserRole.customer:
          context.go(AppConstants.customerHomePath);
          break;
      }
    } else {
      // Unauthenticated -> Login Selection Screen
      context.go(AppConstants.loginSelectionPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
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
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .then(delay: 200.ms)
                .shimmer(duration: 1200.ms),
            const SizedBox(height: 28),
            Text(
              context.l10n.appName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 400.ms).moveY(begin: 15, end: 0),
            const SizedBox(height: 10),
            Text(
              context.l10n.appTagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
                color: AppColors.gold.withValues(alpha: 0.9),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
