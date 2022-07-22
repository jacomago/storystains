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
import 'package:storystains/pages/login_register.dart';

import 'login_register_test.mocks.dart';

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
    WidgetsFlutterBinding.ensureInitialized();
    ServiceLocator.setup();
  });
  tearDown(ServiceLocator.sl.reset);
  group('login', () {
    testWidgets('Log in values', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final widg = wrapWithMaterial(
        Builder(builder: (context) => LoginOrRegisterPage()),
        AuthState(AuthService()),
      );

      await tester.pumpWidget(widg);

      expect(find.bySemanticsLabel('Password'), findsOneWidget);
      expect(find.bySemanticsLabel('Username'), findsOneWidget);

      expect(find.widgetWithText(OutlinedButton, 'Sign up?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Swap Login Register ', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authState = AuthState(AuthService());
      final page = wrapWithMaterial(
        Builder(builder: (context) => LoginOrRegisterPage()),
        authState,
      );

      await tester.pumpWidget(page);

      var swapButton = find.widgetWithText(OutlinedButton, 'Sign up?');
      expect(swapButton, findsOneWidget);

      await tester.ensureVisible(swapButton);
      await tester.tap(swapButton.first);
      await tester.pump();

      swapButton = find.widgetWithText(OutlinedButton, 'Login?');
      expect(swapButton, findsOneWidget);
    });
    testWidgets('Login Failure empty user pass', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authState = AuthState(AuthService());
      final page = wrapWithMaterial(
        Builder(builder: (context) => LoginOrRegisterPage()),
        authState,
      );

      await tester.pumpWidget(page);

      var loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(
          SnackBar,
          "Username can't be blank or Password can't be blank",
        ),
        findsOneWidget,
      );
    });
    testWidgets('Log in network fail', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authService = MockAuthService();
      final authState = AuthState(authService);
      final widg = wrapWithMaterial(
        Builder(builder: (context) => LoginOrRegisterPage()),
        authState,
      );

      await tester.pumpWidget(widg);

      await tester.enterText(find.bySemanticsLabel('Password'), 'password');
      await tester.enterText(find.bySemanticsLabel('Username'), 'username');

      var loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);

      when(authService.login('username', 'password')).thenThrow(
        DioError(
          requestOptions: RequestOptions(path: ''),
          type: DioErrorType.connectTimeout,
        ),
      );
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton.first);
      await tester.pump();

      expect(
        find.widgetWithText(
          SnackBar,
          'Login failed. With Error: Connection timed out',
        ),
        findsOneWidget,
      );
    });
    testWidgets('Register network fail', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authService = MockAuthService();
      final authState = AuthState(authService);
      final page = wrapWithMaterial(
        Builder(builder: (context) => LoginOrRegisterPage()),
        authState,
      );

      await tester.pumpWidget(page);

      var swapButton = find.widgetWithText(OutlinedButton, 'Sign up?');

      await tester.ensureVisible(swapButton);
      await tester.tap(swapButton.first);
      await tester.pump();

      await tester.enterText(find.bySemanticsLabel('Password'), 'password');
      await tester.enterText(find.bySemanticsLabel('Username'), 'username');

      var loginButton = find.widgetWithText(ElevatedButton, 'Sign up');
      expect(loginButton, findsOneWidget);

      when(authService.register('username', 'password')).thenThrow(
        DioError(
          requestOptions: RequestOptions(path: ''),
          type: DioErrorType.connectTimeout,
        ),
      );

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton.first);
      await tester.pump();

      expect(
        find.widgetWithText(
          SnackBar,
          'Sign up failed. With Error: Connection timed out',
        ),
        findsOneWidget,
      );
    });
  });
}
