import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'home_screen.dart';
import '../styles/styles_gallery_screen.dart';
import '../booking/booking_wizard_screen.dart';
import '../appointments/appointments_screen.dart';
import '../profile/profile_screen.dart';

class CustomerNavShell extends ConsumerStatefulWidget {
  final int initialTab;
  const CustomerNavShell({super.key, this.initialTab = 0});

  @override
  ConsumerState<CustomerNavShell> createState() => _CustomerNavShellState();
}

class _CustomerNavShellState extends ConsumerState<CustomerNavShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _tabs = const [
    HomeScreen(),
    StylesGalleryScreen(),
    BookingWizardScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? AppColors.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceBorder, width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                );
              }
              return TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: Theme.of(context).primaryColor, size: 22);
              }
              return IconThemeData(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 22);
            }),
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome.toUpperCase(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.style_outlined),
                selectedIcon: const Icon(Icons.style_rounded),
                label: l10n.navStyles.toUpperCase(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_month_rounded),
                label: l10n.navBooking.toUpperCase(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.access_time_rounded),
                selectedIcon: const Icon(Icons.access_time_filled_rounded),
                label: l10n.navAppointments.toUpperCase(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: l10n.navProfile.toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
