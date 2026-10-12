import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://powhjtyyuincqqaljtzl.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvd2hqdHl5dWluY3FxYWxqdHpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3MjE2NTQsImV4cCI6MjEwNTI5NzY1NH0.nLuC502SfxWbFgNSn0g3OfQ0Hs1U89BMSOsmn2VqzN4',
  );

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint("✅ Afro Men's Beauty Salon: Supabase initialized → $supabaseUrl");
    } catch (e) {
      debugPrint("❌ Afro Men's Beauty Salon: Supabase init failed: $e");
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
