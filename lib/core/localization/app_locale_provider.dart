import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/local_storage_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('am')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final storage = await LocalStorageService.init();
    final savedCode = storage.savedLanguage;
    if (savedCode == 'en') {
      state = const Locale('en');
    } else {
      state = const Locale('am');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (state == newLocale) return;
    state = newLocale;
    final storage = await LocalStorageService.init();
    await storage.setSavedLanguage(newLocale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final nextCode = state.languageCode == 'en' ? 'am' : 'en';
    await setLocale(Locale(nextCode));
  }
}
