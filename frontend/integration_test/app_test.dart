import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:storystains/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
      'tap on the floating action button, verify counter',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Verify the counter starts at 0.
        expect(find.text('Refresh'), findsOneWidget);
      },
    );
  });
}
