import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';

import '../../common/errors.dart';
import '../auth/user.dart';
import 'review.dart';
import 'review_edit_test.mocks.dart';

Widget wrapWithMaterial(
  Widget w,
  ReviewState reviewState, {
  AuthState? authState,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewState>(
          create: (_) => reviewState,
        ),
        ChangeNotifierProvider<AuthState>(
          create: (_) => authState ?? AuthState(AuthService()),
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => EmotionsState(EmotionsService()),
        ),
      ],
      child: MaterialApp(
        home: w,
      ),
    );

@GenerateMocks([ReviewService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    // Not doing a full setup as not testing
    // the network caching of images in the emotions service
    // in this set of tests. The full setup includes the dio
    // http client and so tries to do network requests which don't
    // timeout.
    sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  });
  tearDown(() {
    sl.reset();
  });
  group("Floating button", () {
    testWidgets('can edit when logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // find edit button
      expect(
        find.widgetWithIcon(FloatingActionButton, Icons.edit_note),
        findsOneWidget,
      );
    });
    testWidgets('can send after edit when logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithIcon(FloatingActionButton, Icons.send_rounded),
        findsOneWidget,
      );
    });
    testWidgets('cant edit when not logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
      ));
      // find edit button
      expect(
        find.widgetWithIcon(FloatingActionButton, Icons.edit_note),
        findsNothing,
      );
    });
  });
  group("test edit", () {
    testWidgets('fields exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final titleField = find.widgetWithText(TextField, review.title);
      expect(titleField, findsOneWidget);
      expect(find.text(review.title), findsOneWidget);

      final bodyField = find.widgetWithText(TextField, review.body);
      expect(bodyField, findsOneWidget);
      expect(find.text(review.body), findsOneWidget);

      await tester.enterText(titleField, "title1");
      await tester.pumpAndSettle();
      expect(find.text('title1'), findsOneWidget);

      await tester.enterText(bodyField, "body1");
      await tester.pumpAndSettle();
      expect(find.text('body1'), findsOneWidget);
    });
    testWidgets('error message editing on bad info', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final mockService = MockReviewService();
      final review = testReview(slug: "/");
      final reviewState = ReviewState(mockService, review: review);
      final authState = await loggedInState(username: user.username);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      when(mockService.update(
        review.user.username,
        review.title,
        review.slug,
        review.body,
      )).thenThrow(testApiError(400, "Cannot be /."));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Bad Request: Cannot be /."),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final user = testUser();
      final review = testReview();
      final reviewState = ReviewState(mockService, review: review);

      final authState = await loggedInState(username: user.username);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      await tester.pumpAndSettle();
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      when(mockService.update(
        review.user.username,
        review.slug,
        review.title,
        review.body,
      )).thenAnswer((realInvocation) async => ReviewResp(review: review));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Updated Review"),
        findsOneWidget,
      );
    });
  });
  group("test create", () {
    testWidgets('error message creating on bad info create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title');
      await tester.enterText(titleField, "/");

      final bodyField = find.bySemanticsLabel('Body');
      await tester.enterText(bodyField, "body");
      await tester.pumpAndSettle();

      when(mockService.create("/", "body"))
          .thenThrow(testApiError(400, "Cannot be /."));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Bad Request: Cannot be /."),
        findsOneWidget,
      );
    });
    testWidgets('create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);
      final review = testReview();

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title');
      await tester.enterText(titleField, review.title);

      final bodyField = find.bySemanticsLabel('Body');
      await tester.enterText(bodyField, review.body);
      await tester.pumpAndSettle();

      when(mockService.create(review.title, review.body))
          .thenAnswer((realInvocation) async => ReviewResp(review: review));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, "Updated Review"),
        findsOneWidget,
      );
    });
  });
  group("test delete", () {
    testWidgets('can delete when logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // find menu button
      final menuButton = find.byIcon(Icons.adaptive.more);
      expect(menuButton, findsOneWidget);
    });
    testWidgets('cant delete when not logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
      ));
      // find edit button
      // find menu button
      final menuButton = find.byIcon(Icons.adaptive.more);
      expect(
        menuButton,
        findsNothing,
      );
    });
    testWidgets('delete', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final user = testUser();
      final review = testReview();
      final reviewState = ReviewState(mockService, review: review);
      final authState = await loggedInState(username: user.username);

      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      await tester.pumpAndSettle();

      when(mockService.delete(review.user.username, review.slug))
          .thenAnswer((realInvocation) async => null);

      final menuButton = find.byIcon(Icons.adaptive.more);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      verify(mockService.delete(review.user.username, review.slug));
      expect(
        find.widgetWithText(SnackBar, "Deleted Review"),
        findsOneWidget,
      );
    });
  });
}
