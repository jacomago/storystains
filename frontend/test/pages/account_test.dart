import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/pages/account.dart';

Widget wrapWithMaterial(Widget w, AuthState authState) =>
    ChangeNotifierProvider<AuthState>(
      create: (_) => authState,
      child: MaterialApp(
        home: w,
      ),
    );

void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("account page", () {
    testWidgets('Account values', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final widg = wrapWithMaterial(
        Builder(builder: (BuildContext context) {
          return const AccountPage();
        }),
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

      final widg = wrapWithMaterial(
        Builder(builder: (BuildContext context) {
          return const AccountPage();
        }),
        AuthState(AuthService()),
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
        find.widgetWithText(SnackBar, "Delete user failed"),
        findsOneWidget,
      );
    });
  });
}
