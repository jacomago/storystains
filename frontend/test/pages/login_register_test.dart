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
        home: Scaffold(
          body: w,
        ),
      ),
    );

void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("login", () {
    testWidgets('Log in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authState = AuthState(AuthService());
      await tester
          .pumpWidget(wrapWithMaterial(LoginOrRegisterPage(), authState));
      final passField = find.bySemanticsLabel('Password');
      expect(passField, findsOneWidget);
      final userField = find.bySemanticsLabel('Username');
      expect(userField, findsOneWidget);

      await tester.enterText(passField, "password");
      await tester.pumpAndSettle();
      await tester.enterText(userField, "username");
      await tester.pumpAndSettle();

      var loginButton = find.text("Sign in");
      expect(loginButton, findsOneWidget);

      var swapButton = find.text("New User? Create Account");
      expect(swapButton, findsOneWidget);
      
      await tester.tap(swapButton);
      await tester.pumpAndSettle();

      swapButton = find.text('Has Account? To Login');
      expect(swapButton, findsOneWidget);

      var signupButton = find.text('Sign up');
      expect(signupButton, findsOneWidget);

    });
  });
}

// TODO login
// TODO see failure message
// TODO register
// TODO see failure message
