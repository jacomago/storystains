import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/login_register.dart';
import 'package:storystains/routes/routes.dart';

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

      final mockService = AuthService();
      final authState = AuthState(mockService);
      final widg = wrapWithMaterial(Builder(builder: (BuildContext context) {
        return LoginOrRegisterPage();
      }), authState);

      await tester.pumpWidget(widg);
      await tester.pumpAndSettle();

      final passField = find.bySemanticsLabel('Password');
      expect(passField, findsOneWidget);
      final userField = find.bySemanticsLabel('Username');
      expect(userField, findsOneWidget);

      var swapButton =
          find.widgetWithText(TextButton, "New User? Create Account");
      expect(swapButton, findsOneWidget);
    });

    testWidgets("Swap Login Register ", (tester) async {
      SharedPreferences.setMockInitialValues({});

      final authState = AuthState(AuthService());
      final widg = wrapWithMaterial(Builder(builder: (BuildContext context) {
        return LoginOrRegisterPage();
      }), authState);

      await tester.pumpWidget(widg);

      var swapButton =
          find.widgetWithText(TextButton, "New User? Create Account");
      expect(swapButton, findsOneWidget);

      await tester.ensureVisible(swapButton);
      await tester.tap(swapButton.first);
      await tester.pump();

      swapButton =
          find.widgetWithText(TextButton, "Have Account? To Login");
      expect(swapButton, findsOneWidget);
    });
  });
}

// TODO login
// TODO see failure message
// TODO register
// TODO see failure message
