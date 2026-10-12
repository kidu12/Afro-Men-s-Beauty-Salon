import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/local_storage_service.dart';

enum AppThemeMode {
  luxuryGold,
  ethiopianHeritage,
  modernDark,
  lightPremium;

  String get storageKey {
    switch (this) {
      case AppThemeMode.luxuryGold:
        return 'luxury_gold';
      case AppThemeMode.ethiopianHeritage:
        return 'ethiopian_heritage';
      case AppThemeMode.modernDark:
        return 'modern_dark';
      case AppThemeMode.lightPremium:
        return 'light_premium';
    }
  }

  static AppThemeMode fromKey(String? key) {
    switch (key) {
      case 'ethiopian_heritage':
        return AppThemeMode.ethiopianHeritage;
      case 'modern_dark':
        return AppThemeMode.modernDark;
      case 'light_premium':
        return AppThemeMode.lightPremium;
      case 'luxury_gold':
      default:
        return AppThemeMode.luxuryGold;
    }
  }
}

class AfroColors {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceBorder;
  final Color surfaceHighlight;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color error;
  final Color success;
  final Color warning;
  final LinearGradient brandGradient;
  final LinearGradient cardGradient;
  final LinearGradient glassGradient;

  const AfroColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceBorder,
    required this.surfaceHighlight,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.error,
    required this.success,
    required this.warning,
    required this.brandGradient,
    required this.cardGradient,
    required this.glassGradient,
  });

  // 1. Luxury Gold
  static const luxuryGold = AfroColors(
    background: Color(0xFF0D0D0F),
    surface: Color(0xFF16171B),
    surfaceElevated: Color(0xFF1E2026),
    surfaceBorder: Color(0xFF282A33),
    surfaceHighlight: Color(0xFF2C2F3B),
    primaryAccent: Color(0xFFD4AF37),
    secondaryAccent: Color(0xFFF3E5AB),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA0A0AB),
    textMuted: Color(0xFF6B6B76),
    textInverse: Color(0xFF0D0D0F),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    brandGradient: LinearGradient(
      colors: [Color(0xFFE5C05B), Color(0xFFB88E23)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFF1C1D22), Color(0xFF141518)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    glassGradient: LinearGradient(
      colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 2. Ethiopian Heritage
  static const ethiopianHeritage = AfroColors(
    background: Color(0xFF100C0A),
    surface: Color(0xFF191410),
    surfaceElevated: Color(0xFF241D17),
    surfaceBorder: Color(0xFF332920),
    surfaceHighlight: Color(0xFF3D3126),
    primaryAccent: Color(0xFFF59E0B), // Warm Ethiopian Amber
    secondaryAccent: Color(0xFF10B981), // Ethiopian Emerald Green
    textPrimary: Color(0xFFFAF5EF),
    textSecondary: Color(0xFFBFAFA0),
    textMuted: Color(0xFF7A6D60),
    textInverse: Color(0xFF100C0A),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    brandGradient: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFF211A14), Color(0xFF17120E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    glassGradient: LinearGradient(
      colors: [Color(0x26F59E0B), Color(0x0D10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 3. Modern Dark
  static const modernDark = AfroColors(
    background: Color(0xFF08090C),
    surface: Color(0xFF101218),
    surfaceElevated: Color(0xFF181B24),
    surfaceBorder: Color(0xFF222634),
    surfaceHighlight: Color(0xFF2A3042),
    primaryAccent: Color(0xFF38BDF8), // Platinum Ice Blue
    secondaryAccent: Color(0xFF94A3B8),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    textInverse: Color(0xFF08090C),
    error: Color(0xFFF43F5E),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    brandGradient: LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFF131620), Color(0xFF0D0F16)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    glassGradient: LinearGradient(
      colors: [Color(0x2638BDF8), Color(0x0D38BDF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 4. Light Premium
  static const lightPremium = AfroColors(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F3F5),
    surfaceBorder: Color(0xFFE2E8F0),
    surfaceHighlight: Color(0xFFE2E8F0),
    primaryAccent: Color(0xFFB45309), // Warm Bronze Gold
    secondaryAccent: Color(0xFFD97706),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    textInverse: Color(0xFFFFFFFF),
    error: Color(0xFFDC2626),
    success: Color(0xFF059669),
    warning: Color(0xFFD97706),
    brandGradient: LinearGradient(
      colors: [Color(0xFFD97706), Color(0xFF92400E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    glassGradient: LinearGradient(
      colors: [Color(0x1AD97706), Color(0x05D97706)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

class AppThemeBuilder {
  static ThemeData build(AppThemeMode mode) {
    final colors = getColors(mode);
    final isLight = mode == AppThemeMode.lightPremium;

    final defaultTextTheme = isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Outfit',
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primaryAccent,
      colorScheme: isLight
          ? ColorScheme.light(
              primary: colors.primaryAccent,
              onPrimary: colors.textInverse,
              surface: colors.surface,
              onSurface: colors.textPrimary,
              error: colors.error,
              onError: Colors.white,
            )
          : ColorScheme.dark(
              primary: colors.primaryAccent,
              onPrimary: colors.textInverse,
              surface: colors.surface,
              onSurface: colors.textPrimary,
              error: colors.error,
              onError: Colors.white,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      textTheme: defaultTextTheme.copyWith(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.surfaceBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryAccent,
          foregroundColor: colors.textInverse,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.surfaceBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.surfaceBorder,
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primaryAccent,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }

  static AfroColors getColors(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.ethiopianHeritage:
        return AfroColors.ethiopianHeritage;
      case AppThemeMode.modernDark:
        return AfroColors.modernDark;
      case AppThemeMode.lightPremium:
        return AfroColors.lightPremium;
      case AppThemeMode.luxuryGold:
        return AfroColors.luxuryGold;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.luxuryGold) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final storage = await LocalStorageService.init();
    state = AppThemeMode.fromKey(storage.savedTheme);
  }

  Future<void> setTheme(AppThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final storage = await LocalStorageService.init();
    await storage.setSavedTheme(mode.storageKey);
  }
}
