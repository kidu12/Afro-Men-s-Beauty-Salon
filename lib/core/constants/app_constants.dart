class AppConstants {
  static const String appName = "Afro Men's Beauty Salon";
  static const String appTagline = 'Style starts here.';
  static const String defaultTimezone = 'Africa/Addis_Ababa';
  static const String currencyCode = 'ETB';

  // Storage Buckets
  static const String hairstyleBucket = 'hairstyles';
  static const String avatarBucket = 'avatars';
  static const String portfolioBucket = 'portfolios';

  // Startup & Auth Routes
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String loginSelectionPath = '/login-selection';
  static const String customerLoginPath = '/customer/login';
  static const String customerRegisterPath = '/customer/register';
  static const String staffLoginPath = '/staff/login';

  // Customer Navigation Routes
  static const String customerHomePath = '/customer/home';
  static const String customerStylesPath = '/customer/styles';
  static const String customerServicesPath = '/customer/services';
  static const String customerBarbersPath = '/customer/barbers';
  static const String customerBookingPath = '/customer/booking';
  static const String customerAppointmentsPath = '/customer/appointments';
  static const String customerProfilePath = '/customer/profile';
  static const String favoritesPath = '/customer/favorites';
  static const String notificationsPath = '/customer/notifications';
  static const String shopInfoPath = '/customer/shop-info';

  // Detail Paths
  static const String styleDetailPath = '/customer/style-detail';
  static const String barberDetailPath = '/customer/barber-detail';

  // Barber Portal Routes
  static const String barberDashboardPath = '/barber/dashboard';
  static const String barberAppointmentsPath = '/barber/appointments';
  static const String barberProfilePath = '/barber/profile';

  // Admin Portal Routes
  static const String adminDashboardPath = '/admin/dashboard';
  static const String adminAppointmentsPath = '/admin/appointments';
  static const String adminBarbersPath = '/admin/barbers';
  static const String adminServicesPath = '/admin/services';
  static const String adminStylesPath = '/admin/styles';
  static const String adminHoursPath = '/admin/business-hours';
  static const String adminSettingsPath = '/admin/settings';

  // Backward compatibility aliases
  static const String loginPath = loginSelectionPath;
  static const String registerPath = customerRegisterPath;
  static const String homePath = customerHomePath;
  static const String stylesPath = customerStylesPath;
  static const String bookingPath = customerBookingPath;
  static const String appointmentsPath = customerAppointmentsPath;
  static const String profilePath = customerProfilePath;
  static const String barberPortalPath = barberDashboardPath;
}
