import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/login_register.dart';

Widget wrapWithMaterial(Widget w, AuthState authState) =>
    ChangeNotifierProvider<AuthState>(
      create: (_) => authState,
      child: MaterialApp(
        home: w,
      ),
    );

void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("login", () {
    testWidgets('Log in values', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final widg = wrapWithMaterial(
        Builder(builder: (BuildContext context) {
          return LoginOrRegisterPage();
        }),
        AuthState(AuthService()),
      );

      await tester.pumpWidget(widg);

      expect(find.bySemanticsLabel('Password'), findsOneWidget);
      expect(find.bySemanticsLabel('Username'), findsOneWidget);

      expect(find.widgetWithText(TextButton, "Register?"), findsOneWidget);
      expect(find.widgetWithText(MaterialButton, "Login"), findsOneWidget);
    });

    testWidgets("Swap Login Register ", (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authState = AuthState(AuthService());
      final page = wrapWithMaterial(
        Builder(builder: (BuildContext context) {
          return LoginOrRegisterPage();
        }),
        authState,
      );

      await tester.pumpWidget(page);

      var swapButton = find.widgetWithText(TextButton, "Register?");
      expect(swapButton, findsOneWidget);

      await tester.ensureVisible(swapButton);
      await tester.tap(swapButton.first);
      await tester.pump();

      swapButton = find.widgetWithText(TextButton, "Login?");
      expect(swapButton, findsOneWidget);
    });
    testWidgets("Login Failure empty user pass", (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authState = AuthState(AuthService());
      final page = wrapWithMaterial(
        Builder(builder: (BuildContext context) {
          return LoginOrRegisterPage();
        }),
        authState,
      );

      await tester.pumpWidget(page);

      var loginButton = find.widgetWithText(MaterialButton, "Login");
      expect(loginButton, findsOneWidget);

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton.first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Wrong username or password."),
        findsOneWidget,
      );
    });
    testWidgets('Log in network fail', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final widg = wrapWithMaterial(
        Builder(builder: (BuildContext context) {
          return LoginOrRegisterPage();
        }),
        AuthState(
          AuthService(),
        ),
      );

      await tester.pumpWidget(widg);

      await tester.enterText(find.bySemanticsLabel('Password'), "password");
      await tester.enterText(find.bySemanticsLabel('Username'), "username");

      var loginButton = find.widgetWithText(MaterialButton, "Login");
      expect(loginButton, findsOneWidget);

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton.first);
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Sign in failed. Please try again."),
        findsOneWidget,
      );
    });
  });
}

// TODO see failure message
// TODO register
// TODO see failure message
