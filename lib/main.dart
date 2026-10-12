import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_locale_provider.dart';
import 'core/theme/app_theme_provider.dart';
import 'core/routing/app_router.dart';
import 'data/services/supabase_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {
  // Background notification handler entry point
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialize Supabase (cloud database — no local server needed) ────────
  await SupabaseService.initialize();

  if (kDebugMode) {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════╗');
    debugPrint('║  [SUPABASE] Connected to cloud database ☁️           ║');
    debugPrint('║  URL: ${SupabaseService.supabaseUrl}');
    debugPrint('╚══════════════════════════════════════════════════════╝');
    debugPrint('');
  }

  runApp(const AfroBarberApp());
}

class AfroBarberApp extends StatefulWidget {
  const AfroBarberApp({super.key});

  @override
  State<AfroBarberApp> createState() => _AfroBarberAppState();
}

class _AfroBarberAppState extends State<AfroBarberApp> {
  late final ProviderContainer _container;
  late final router = buildAppRouter(_container);

  @override
  void initState() {
    super.initState();
    _container = ProviderContainer();
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(localeProvider);
          final themeMode = ref.watch(themeProvider);
          final themeData = AppThemeBuilder.build(themeMode);

          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        },
      ),
    );
  }
}
