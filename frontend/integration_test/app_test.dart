import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:storystains/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
      'full-app-flow',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        // Signup user
        await tester.tap(find.widgetWithIcon(IconButton, Icons.login));
        await tester.pumpAndSettle();

        var swapButton = find.widgetWithText(TextButton, "Register?");
        await tester.ensureVisible(swapButton);
        await tester.tap(swapButton.first);
        await tester.pump();

        final username1 = "randomusername1${Random().nextInt(100)}";
        await tester.enterText(
          find.bySemanticsLabel('Username'),
          username1,
        );
        const password1 = "randompassword1";
        await tester.enterText(
          find.bySemanticsLabel('Password'),
          password1,
        );

        var loginButton = find.widgetWithText(MaterialButton, "Register");
        expect(loginButton, findsOneWidget);

        await tester.ensureVisible(loginButton);
        await tester.tap(loginButton.first);
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(SnackBar, "Signed in as $username1"),
          findsOneWidget,
        );
        // TODO create multiple reviews
        // TODO create multiple review emotions
        // TODO edit review
        // TODO edit review emotion
        // TODO see all review details in list view
        // TODO see all review details
        // TODO delete review emotion
        // TODO delete review with review emotions
        // TODO logout
        // TODO create other user
        // TODO create a review with emotions
        // TODO cannot edit others reviews
        // TODO cannot add review emotion to another review
        // TODO logout
        // TODO cannot create a review
        // TODO login as first user
        // TODO delete user
        // TODO see the other users review still

        // Verify the counter starts at 0.
        expect(find.text('Refresh'), findsOneWidget);
      },
    );
  });
}
