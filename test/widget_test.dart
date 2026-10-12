import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afro_barber/main.dart';
import 'package:afro_barber/core/constants/app_constants.dart';
import 'package:afro_barber/data/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  testWidgets('Afro-Barber app launches and renders splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const AfroBarberApp());
    await tester.pump();

    // Initial render
    expect(find.text(AppConstants.appName.toUpperCase()), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    // Drain navigation timer and flutter_animate timers
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
  });
}
