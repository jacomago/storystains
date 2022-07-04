import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/account.dart';

Widget wrapWithMaterial(Widget w, AuthState authState) =>
    ChangeNotifierProvider<AuthState>(
      create: (_) => authState,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: w,
      ),
    );

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized;
    final dio = ServiceLocator.setupDio();
    ServiceLocator.setupRest(dio);
    ServiceLocator.setupSecureStorage();
  });
  tearDown(ServiceLocator.sl.reset);
  group('account page', () {
    testWidgets('Account values', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final widg = wrapWithMaterial(
        Builder(builder: (context) => const AccountPage()),
        AuthState(AuthService()),
      );

      await tester.pumpWidget(widg);

      expect(
        find.widgetWithText(OutlinedButton, 'Delete User'),
        findsOneWidget,
      );
    });
    testWidgets('Account delete', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authState = AuthState(AuthService());
      ServiceLocator.sl.registerSingleton(authState);
      final widg = wrapWithMaterial(
        Builder(builder: (context) => const AccountPage()),
        authState,
      );

      await tester.pumpWidget(widg);

      var button = find.widgetWithText(OutlinedButton, 'Delete User');
      expect(button, findsOneWidget);

      await tester.ensureVisible(button);
      await tester.tap(button.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Delete User failed.'),
        findsOneWidget,
      );
    });
    testWidgets('Account log out', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final widg = wrapWithMaterial(
        Builder(builder: (context) => const AccountPage()),
        AuthState(AuthService()),
      );

      await tester.pumpWidget(widg);

      var button = find.widgetWithText(ElevatedButton, 'Logout');
      expect(button, findsOneWidget);

      await tester.ensureVisible(button);
      await tester.tap(button.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Logout succeded.'),
        findsOneWidget,
      );
    });
  });
}
