import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/account.dart';

import '../common/errors.dart';
import 'account_test.mocks.dart';

Widget wrapWithMaterial(Widget w, AuthState authState) =>
    ChangeNotifierProvider<AuthState>(
      create: (_) => authState,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: w,
      ),
    );

@GenerateMocks([AuthService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized;
    final dio = ServiceLocator.setupDio(PersistCookieJar());
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
      await tester.pumpAndSettle();
    });
    testWidgets('Account delete', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authService = MockAuthService();
      when(authService.getUser())
          .thenThrow(testApiError(401, 'Not logged in.'));
      final authState = AuthState(authService);
      ServiceLocator.sl.registerSingleton(authState);
      final widg = wrapWithMaterial(
        Builder(builder: (context) => const AccountPage()),
        authState,
      );

      await tester.pumpWidget(widg);

      var button = find.widgetWithText(OutlinedButton, 'Delete User');
      expect(button, findsOneWidget);

      when(authService.delete()).thenThrow(
        DioError(
          requestOptions: RequestOptions(path: ''),
          type: DioErrorType.connectTimeout,
        ),
      );

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

      final authService = MockAuthService();
      when(authService.getUser())
          .thenThrow(testApiError(401, 'Not logged in.'));
      final authState = AuthState(authService);
      final widg = wrapWithMaterial(
        Builder(builder: (context) => const AccountPage()),
        authState,
      );

      await tester.pumpWidget(widg);

      var button = find.widgetWithText(ElevatedButton, 'Logout');
      expect(button, findsOneWidget);

      // ignore: no-empty-block
      when(authService.logout()).thenAnswer((realInvocation) async {});

      await tester.ensureVisible(button);
      await tester.tap(button.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Logout succeeded.'),
        findsOneWidget,
      );
    });
  });
}
