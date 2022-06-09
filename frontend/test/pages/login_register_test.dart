import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/login_register.dart';

Widget wrapWithMaterial(Widget w) => MaterialApp(
      home: ChangeNotifierProvider<AuthState>(
        create: (_) => AuthState(AuthService()),
        child: Scaffold(
          body: w,
        ),
      ),
    );


void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("login", () {
    testWidgets('After logging in isAuthenticated', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(wrapWithMaterial(LoginOrRegisterPage()));
      final passField = find.bySemanticsLabel('Password');
      expect(passField, findsOneWidget);
      final userField = find.bySemanticsLabel('Username');
      expect(userField, findsOneWidget);

    });
  });
}

// TODO change register and login
// TODO fill in details
// TODO login
// TODO see failure message
// TODO register
// TODO see failure message
