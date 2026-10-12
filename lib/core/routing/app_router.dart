import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../data/models/user_profile.dart';
import '../../features/auth/auth_state_provider.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_selection_screen.dart';
import '../../features/auth/customer_login_screen.dart';
import '../../features/auth/staff_login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/customer_nav_shell.dart';
import '../../features/services/services_screen.dart';
import '../../features/styles/style_detail_screen.dart';
import '../../features/barbers/barber_profile_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/shop_info_screen.dart';
import '../../features/barber_portal/barber_dashboard_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_services_screen.dart';
import '../../features/admin/admin_barbers_screen.dart';
import '../../features/admin/admin_styles_screen.dart';
import '../../features/admin/admin_appointments_screen.dart';
import '../../features/admin/admin_hours_screen.dart';

// ---------------------------------------------------------------------------
// Auth/role notifier listenable for GoRouter refresh
// ---------------------------------------------------------------------------
final _routerNotifier = _RouterNotifier();

class _RouterNotifier extends ChangeNotifier {
  ProviderSubscription<AuthState>? _sub;

  void attach(ProviderContainer container) {
    _sub?.close();
    _sub = container.listen<AuthState>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Route group helpers
// ---------------------------------------------------------------------------
bool _isCustomerRoute(String path) => path.startsWith('/customer/');
bool _isBarberRoute(String path) => path.startsWith('/barber/');
bool _isAdminRoute(String path) => path.startsWith('/admin/');
bool _isProtectedRoute(String path) =>
    _isCustomerRoute(path) || _isBarberRoute(path) || _isAdminRoute(path);

// ---------------------------------------------------------------------------
// Router factory — call once from main after ProviderContainer is set up.
// For simplicity we use a module-level instance and a global container ref.
// ---------------------------------------------------------------------------
GoRouter buildAppRouter(ProviderContainer container) {
  _routerNotifier.attach(container);

  return GoRouter(
    initialLocation: AppConstants.splashPath,
    refreshListenable: _routerNotifier,

    // ── Global redirect guard ──────────────────────────────────────────────
    redirect: (context, state) {
      final authState = container.read(authStateProvider);
      final location = state.matchedLocation;

      // Still loading — let the splash handle navigation
      if (authState.isLoading) return null;

      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;

      // Public routes — never redirect
      if (location == AppConstants.splashPath ||
          location == AppConstants.onboardingPath ||
          location == AppConstants.loginSelectionPath ||
          location == AppConstants.customerLoginPath ||
          location == AppConstants.customerRegisterPath ||
          location == AppConstants.staffLoginPath ||
          location == '/login' ||
          location == '/register') {
        return null;
      }

      // Unauthenticated user trying to access a protected route
      if (!isAuthenticated && _isProtectedRoute(location)) {
        if (kDebugMode) {
          debugPrint('[ROUTER] Unauthenticated access to $location → /login-selection');
        }
        return AppConstants.loginSelectionPath;
      }

      if (isAuthenticated && user != null) {
        final role = user.role;

        // Customer trying to access admin or barber routes
        if (role == UserRole.customer && (_isAdminRoute(location) || _isBarberRoute(location))) {
          if (kDebugMode) {
            debugPrint('[ROUTER] Customer blocked from $location → /customer/home');
          }
          return AppConstants.customerHomePath;
        }

        // Barber trying to access admin routes
        if (role == UserRole.barber && _isAdminRoute(location)) {
          if (kDebugMode) {
            debugPrint('[ROUTER] Barber blocked from $location → /barber/dashboard');
          }
          return AppConstants.barberDashboardPath;
        }
      }

      return null;
    },

    routes: [
      // 1. Startup
      GoRoute(
        path: AppConstants.splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 2. Authentication Selection & Portals
      GoRoute(
        path: AppConstants.loginSelectionPath,
        builder: (context, state) => const LoginSelectionScreen(),
      ),
      GoRoute(
        path: AppConstants.customerLoginPath,
        builder: (context, state) => const CustomerLoginScreen(),
      ),
      GoRoute(
        path: AppConstants.customerRegisterPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.staffLoginPath,
        builder: (context, state) => const StaffLoginScreen(),
      ),
      // Fallback aliases for auth
      GoRoute(
        path: '/login',
        redirect: (_, __) => AppConstants.loginSelectionPath,
      ),
      GoRoute(
        path: '/register',
        redirect: (_, __) => AppConstants.customerRegisterPath,
      ),

      // 3. Customer Portal Routes
      GoRoute(
        path: AppConstants.customerHomePath,
        builder: (context, state) => const CustomerNavShell(initialTab: 0),
      ),
      GoRoute(
        path: AppConstants.customerStylesPath,
        builder: (context, state) => const CustomerNavShell(initialTab: 1),
      ),
      GoRoute(
        path: AppConstants.customerServicesPath,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: AppConstants.customerBarbersPath,
        builder: (context, state) =>
            const BarberProfileScreen(barberId: 'barber-mike'),
      ),
      GoRoute(
        path: AppConstants.customerBookingPath,
        builder: (context, state) => const CustomerNavShell(initialTab: 2),
      ),
      GoRoute(
        path: AppConstants.customerAppointmentsPath,
        builder: (context, state) => const CustomerNavShell(initialTab: 3),
      ),
      GoRoute(
        path: AppConstants.customerProfilePath,
        builder: (context, state) => const CustomerNavShell(initialTab: 4),
      ),
      GoRoute(
        path: AppConstants.favoritesPath,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppConstants.notificationsPath,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppConstants.shopInfoPath,
        builder: (context, state) => const ShopInfoScreen(),
      ),
      GoRoute(
        path: AppConstants.styleDetailPath,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'style-1';
          return StyleDetailScreen(styleId: id);
        },
      ),
      GoRoute(
        path: AppConstants.barberDetailPath,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'barber-mike';
          return BarberProfileScreen(barberId: id);
        },
      ),

      // Backward compatibility customer aliases
      GoRoute(path: '/home', redirect: (_, __) => AppConstants.customerHomePath),
      GoRoute(path: '/styles', redirect: (_, __) => AppConstants.customerStylesPath),
      GoRoute(path: '/booking', redirect: (_, __) => AppConstants.customerBookingPath),
      GoRoute(path: '/appointments', redirect: (_, __) => AppConstants.customerAppointmentsPath),
      GoRoute(path: '/profile', redirect: (_, __) => AppConstants.customerProfilePath),
      GoRoute(path: '/favorites', redirect: (_, __) => AppConstants.favoritesPath),
      GoRoute(path: '/notifications', redirect: (_, __) => AppConstants.notificationsPath),
      GoRoute(path: '/shop-info', redirect: (_, __) => AppConstants.shopInfoPath),
      GoRoute(
          path: '/style-detail',
          redirect: (_, state) =>
              '${AppConstants.styleDetailPath}?id=${state.uri.queryParameters['id'] ?? "style-1"}'),
      GoRoute(
          path: '/barber-detail',
          redirect: (_, state) =>
              '${AppConstants.barberDetailPath}?id=${state.uri.queryParameters['id'] ?? "barber-mike"}'),

      // 4. Barber Portal Routes
      GoRoute(
        path: AppConstants.barberDashboardPath,
        builder: (context, state) => const BarberDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.barberAppointmentsPath,
        builder: (context, state) => const BarberDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.barberProfilePath,
        builder: (context, state) => const ShopInfoScreen(),
      ),
      GoRoute(
          path: '/barber-portal',
          redirect: (_, __) => AppConstants.barberDashboardPath),

      // 5. Admin Portal Routes
      GoRoute(
        path: AppConstants.adminDashboardPath,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.adminAppointmentsPath,
        builder: (context, state) => const AdminAppointmentsScreen(),
      ),
      GoRoute(
        path: AppConstants.adminBarbersPath,
        builder: (context, state) => const AdminBarbersScreen(),
      ),
      GoRoute(
        path: AppConstants.adminServicesPath,
        builder: (context, state) => const AdminServicesScreen(),
      ),
      GoRoute(
        path: AppConstants.adminStylesPath,
        builder: (context, state) => const AdminStylesScreen(),
      ),
      GoRoute(
        path: AppConstants.adminHoursPath,
        builder: (context, state) => const AdminHoursScreen(),
      ),
      GoRoute(
        path: AppConstants.adminSettingsPath,
        builder: (context, state) => const ShopInfoScreen(),
      ),
      GoRoute(path: '/admin-dashboard', redirect: (_, __) => AppConstants.adminDashboardPath),
      GoRoute(path: '/admin-appointments', redirect: (_, __) => AppConstants.adminAppointmentsPath),
      GoRoute(path: '/admin-barbers', redirect: (_, __) => AppConstants.adminBarbersPath),
      GoRoute(path: '/admin-services', redirect: (_, __) => AppConstants.adminServicesPath),
      GoRoute(path: '/admin-styles', redirect: (_, __) => AppConstants.adminStylesPath),
      GoRoute(path: '/admin-hours', redirect: (_, __) => AppConstants.adminHoursPath),
    ],
  );
}

// Legacy singleton for screens that import appRouter directly.
// Replaced by buildAppRouter() when ProviderContainer is available.
final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.splashPath,
  routes: [
    GoRoute(
      path: AppConstants.splashPath,
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
