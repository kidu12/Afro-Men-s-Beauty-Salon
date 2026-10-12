import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../../core/errors/app_exceptions.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  /// Returns the currently logged-in user from Supabase session + profiles table.
  Future<UserProfile?> getCurrentProfile() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) {
      _currentUser = null;
      return null;
    }

    try {
      final uid = session.user.id;
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data == null) {
        _currentUser = null;
        return null;
      }

      _currentUser = UserProfile.fromJson(data);
      return _currentUser;
    } catch (e) {
      if (kDebugMode) debugPrint('[AUTH] getCurrentProfile error: $e');
      _currentUser = null;
      return null;
    }
  }

  /// Sign in with email + password via Supabase Auth, then fetch profile row.
  Future<UserProfile> loginWithEmail(String email, String password) async {
    try {
      if (kDebugMode) {
        debugPrint('[AUTH] Signing in with Supabase Auth → email: $email');
      }

      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Login failed. Please check your credentials.');
      }

      final uid = response.user!.id;

      // Fetch the profile row to get role, full_name, etc.
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data == null) {
        // Create a minimal profile if somehow missing
        _currentUser = UserProfile(
          id: uid,
          fullName: response.user!.email ?? 'User',
          email: response.user!.email,
          role: UserRole.customer,
          createdAt: DateTime.now(),
        );
        return _currentUser!;
      }

      final profile = UserProfile.fromJson(data);
      _currentUser = profile;

      if (kDebugMode) {
        debugPrint('[AUTH] Login successful. Role: ${profile.role.name}');
      }

      return profile;
    } on AuthException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[AUTH] loginWithEmail error: $e');
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Register a new user via Supabase Auth, then insert a profile row.
  Future<UserProfile> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );

      if (response.user == null) {
        throw AuthException('Registration failed. Please try again.');
      }

      final uid = response.user!.id;

      // Try updating the profile directly if session is active; otherwise the database trigger handles it
      try {
        await SupabaseService.client.from('profiles').upsert({
          'id': uid,
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'role': 'customer',
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AUTH] Profile direct upsert skipped (handled by DB trigger): $e');
        }
      }

      // If no session was returned, attempt an immediate login
      if (response.session == null) {
        try {
          await SupabaseService.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (_) {}
      }

      final profile = UserProfile(
        id: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );

      _currentUser = profile;
      return profile;
    } on AuthException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[AUTH] registerUser error: $e');
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await SupabaseService.client.auth.signOut();
  }
}
