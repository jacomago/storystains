import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';

import '../features/review/review.dart';

Widget wrapWithMaterial(
  Widget w,
  ReviewState reviewState,
  AuthState authState,
) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewState>(
          create: (_) => reviewState,
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider<AuthState>(
          create: (_) => authState,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: w,
        ),
      ),
    );

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    ServiceLocator.setup();
  });
  tearDown(ServiceLocator.sl.reset);
  group('Read Review', () {
    testWidgets('fields exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();
      final reviewState = ReviewState(
        ReviewService(),
        review: review,
      );
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        AuthState(AuthService()),
      ));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title');
      expect(titleField, findsOneWidget);
      expect(find.text(review.story.title), findsOneWidget);

      expect(find.text(review.body), findsOneWidget);

      expect(find.text('@${review.user.username}'), findsOneWidget);
      expect(
        find.text(DateFormat.yMMMMEEEEd().format(review.updatedAt)),
        findsOneWidget,
      );
    });
    testWidgets('block edit only copy', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final review = testReview();
      final reviewState = ReviewState(ReviewService(), review: review);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        AuthState(AuthService()),
      ));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithIcon(FloatingActionButton, Icons.copy),
        findsOneWidget,
      );
    });
  });
}
