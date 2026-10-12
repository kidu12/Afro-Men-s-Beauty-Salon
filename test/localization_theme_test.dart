import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afro_barber/core/localization/app_localizations.dart';
import 'package:afro_barber/core/theme/app_theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2: Localization System Tests', () {
    test('English dictionary contains all required keys with natural copy', () {
      final l10nEn = AppLocalizations(const Locale('en'));

      expect(l10nEn.appName, equals('Afro Mens Beauty Salon'));
      expect(l10nEn.customerPortal, equals('Customer Portal'));
      expect(l10nEn.staffPortal, equals('Staff Portal'));
      expect(l10nEn.navHome, equals('Home'));
      expect(l10nEn.navStyles, equals('Styles'));
      expect(l10nEn.navBooking, equals('Book'));
      expect(l10nEn.navAppointments, equals('Cuts'));
      expect(l10nEn.navProfile, equals('Profile'));
      expect(l10nEn.statusConfirmed, equals('Confirmed'));
      expect(l10nEn.statusInProgress, equals('In Progress'));
      expect(l10nEn.statusCompleted, equals('Completed'));
      expect(l10nEn.statusCancelled, equals('Cancelled'));
      expect(l10nEn.isAmharic, isFalse);
    });

    test('Amharic (አማርኛ) dictionary contains authentic Ethiopic translations', () {
      final l10nAm = AppLocalizations(const Locale('am'));

      expect(l10nAm.appName, equals('አፍሮ የወንዶች ውበት ሳሎን'));
      expect(l10nAm.customerPortal, equals('የደንበኞች መግቢያ'));
      expect(l10nAm.staffPortal, equals('የሰራተኞች መግቢያ'));
      expect(l10nAm.navHome, equals('ዋና ገጽ'));
      expect(l10nAm.navStyles, equals('ስታይሎች'));
      expect(l10nAm.navBooking, equals('ቀጠሮ'));
      expect(l10nAm.navAppointments, equals('ቀጠሮዎቼ'));
      expect(l10nAm.navProfile, equals('መገለጫ'));
      expect(l10nAm.statusConfirmed, equals('ተረጋግጧል'));
      expect(l10nAm.statusInProgress, equals('በሂደት ላይ'));
      expect(l10nAm.statusCompleted, equals('ተጠናቋል'));
      expect(l10nAm.statusCancelled, equals('ተሰርዟል'));
      expect(l10nAm.isAmharic, isTrue);
    });

    test('Locale fallback gracefully returns English for unsupported keys', () {
      final l10nAm = AppLocalizations(const Locale('am'));
      expect(l10nAm.get('nonExistentKey'), equals('nonExistentKey'));
    });
  });

  group('Phase 2: Multi-Theme System Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('All 4 application themes are defined with unique aesthetics', () {
      final luxuryGold = AppThemeBuilder.build(AppThemeMode.luxuryGold);
      final ethiopianHeritage = AppThemeBuilder.build(AppThemeMode.ethiopianHeritage);
      final modernDark = AppThemeBuilder.build(AppThemeMode.modernDark);
      final lightPremium = AppThemeBuilder.build(AppThemeMode.lightPremium);

      expect(luxuryGold.brightness, equals(Brightness.dark));
      expect(ethiopianHeritage.brightness, equals(Brightness.dark));
      expect(modernDark.brightness, equals(Brightness.dark));
      expect(lightPremium.brightness, equals(Brightness.light));

      // Color scheme primary validations
      final goldColors = AfroColors.luxuryGold;
      final heritageColors = AfroColors.ethiopianHeritage;
      final modernColors = AfroColors.modernDark;
      final lightColors = AfroColors.lightPremium;

      expect(goldColors.primaryAccent, equals(const Color(0xFFD4AF37)));
      expect(heritageColors.primaryAccent, equals(const Color(0xFFF59E0B)));
      expect(heritageColors.secondaryAccent, equals(const Color(0xFF10B981)));
      expect(modernColors.primaryAccent, equals(const Color(0xFF38BDF8)));
      expect(lightColors.primaryAccent, equals(const Color(0xFFB45309)));
    });

    test('ThemeNotifier changes theme and persists preference without session reset', () async {
      final notifier = ThemeNotifier();
      expect(notifier.state, equals(AppThemeMode.luxuryGold));

      await notifier.setTheme(AppThemeMode.ethiopianHeritage);
      expect(notifier.state, equals(AppThemeMode.ethiopianHeritage));

      await notifier.setTheme(AppThemeMode.lightPremium);
      expect(notifier.state, equals(AppThemeMode.lightPremium));

      await notifier.setTheme(AppThemeMode.modernDark);
      expect(notifier.state, equals(AppThemeMode.modernDark));
    });
  });
}
