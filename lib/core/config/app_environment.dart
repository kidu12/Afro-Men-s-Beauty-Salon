import 'package:flutter/foundation.dart';

enum EnvironmentType {
  development,
  staging,
  production;

  static EnvironmentType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'production':
      case 'prod':
        return EnvironmentType.production;
      case 'staging':
        return EnvironmentType.staging;
      case 'development':
      case 'dev':
      default:
        return EnvironmentType.development;
    }
  }
}

class AppEnvironment {
  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: kDebugMode ? 'development' : 'production',
  );

  static final EnvironmentType current = EnvironmentType.fromString(_envName);

  static bool get isProduction => current == EnvironmentType.production;
  static bool get isDevelopment => current == EnvironmentType.development;

  /// Debug tools and demo role switchers are only visible in development builds.
  /// Strictly disabled in release/production builds.
  static bool get showDevTools => kDebugMode && isDevelopment;

  static const String businessTimezone = 'Africa/Addis_Ababa';
}
