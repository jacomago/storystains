import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/login_register.dart';
import 'package:storystains/routes/routes.dart';

import 'login_register_test.mocks.dart';

Widget wrapWithMaterial(Widget w, AuthState authState) =>
    ChangeNotifierProvider<AuthState>(
      create: (_) => authState,
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
        onGenerateRoute: routes,
      ),
    );

@GenerateMocks([AuthState])
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

      final authState = MockAuthState();
      final widg = wrapWithMaterial(Builder(builder: (BuildContext context) {
        return LoginOrRegisterPage();
      }), authState);

      when(authState.isLogin).thenAnswer((realInvocation) => true);
      when(authState.isLogin).thenAnswer((realInvocation) => true);

      await tester.pumpWidget(widg);
      await tester.pumpAndSettle();

      var swapButton =
          find.widgetWithText(TextButton, "New User? Create Account");
      expect(swapButton, findsOneWidget);

      when(authState.switchLoginRegister())
          .thenAnswer((realInvocation) async => {});
      when(authState.isLogin).thenAnswer((realInvocation) => false);
      when(authState.isLogin).thenAnswer((realInvocation) => false);

      await tester.runAsync(() async => {await tester.tap(swapButton)});

      await tester.pumpAndSettle();

      verify(authState.switchLoginRegister());

      swapButton = find.text("Have Account? To Login");
      expect(swapButton, findsOneWidget);

      var loginButton = find.widgetWithText(MaterialButton, "Sign in");
      expect(loginButton, findsOneWidget);
    });
  });
}

// TODO login
// TODO see failure message
// TODO register
// TODO see failure message
