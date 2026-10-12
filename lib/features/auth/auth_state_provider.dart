import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  loadingProfile,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null;

  const AuthState.authenticating()
      : status = AuthStatus.authenticating,
        user = null,
        errorMessage = null;

  const AuthState.loadingProfile()
      : status = AuthStatus.loadingProfile,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.authenticating || status == AuthStatus.loadingProfile;
  UserProfile? get value => user;

  T when<T>({
    required T Function(UserProfile? user) data,
    required T Function(Object error, StackTrace? stackTrace) error,
    required T Function() loading,
  }) {
    if (isLoading) return loading();
    if (status == AuthStatus.error) {
      return error(errorMessage ?? 'Authentication error', null);
    }
    return data(user);
  }

  T maybeWhen<T>({
    T Function(UserProfile? user)? data,
    T Function(Object error, StackTrace? stackTrace)? error,
    T Function()? loading,
    required T Function() orElse,
  }) {
    if (isLoading && loading != null) return loading();
    if (status == AuthStatus.error && error != null) {
      return error(errorMessage ?? 'Authentication error', null);
    }
    if (data != null && (status == AuthStatus.authenticated || status == AuthStatus.unauthenticated)) {
      return data(user);
    }
    return orElse();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState.loadingProfile()) {
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    state = const AuthState.loadingProfile();
    try {
      final profile = await _repo.getCurrentProfile();
      if (profile != null) {
        state = AuthState.authenticated(profile);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<UserProfile> loginCustomer(String identifier, String password) async {
    state = const AuthState.authenticating();
    try {
      final profile = await _repo.loginWithEmail(identifier, password);
      if (profile.role != UserRole.customer) {
        await _repo.signOut();
        state = const AuthState.unauthenticated();
        throw Exception('This account belongs to the staff portal. Please use Staff Login.');
      }
      state = AuthState.authenticated(profile);
      return profile;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      rethrow;
    }
  }

  Future<UserProfile> loginStaff(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final profile = await _repo.loginWithEmail(email, password);
      if (profile.role == UserRole.customer) {
        await _repo.signOut();
        state = const AuthState.unauthenticated();
        throw Exception('This account is registered as a customer.');
      }
      state = AuthState.authenticated(profile);
      return profile;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      rethrow;
    }
  }

  Future<UserProfile> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AuthState.authenticating();
    try {
      final profile = await _repo.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      state = AuthState.authenticated(profile);
      return profile;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState.unauthenticated();
  }
}
