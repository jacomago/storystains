import 'dart:io' as io;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/features/review_emotions/review_emotions.dart';
import 'package:storystains/features/story/story.dart';

import '../../common/errors.dart';
import '../../common/image_mock_http.dart';
import '../auth/user.dart';
import '../review_emotion/review_emotion.dart';
import '../story/story.dart';
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
        ChangeNotifierProvider<MediumsState>(
          create: (_) => MediumsState(MediumsService()),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
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
    io.HttpOverrides.global = TestHttpOverrides();
    final dio = ServiceLocator.setupDio(PersistCookieJar());
    ServiceLocator.setupRest(dio);
    ServiceLocator.setupSecureStorage();
  });
  tearDown(ServiceLocator.sl.reset);
  group('Floating button', () {
    testWidgets('can edit when logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      ServiceLocator.sl.registerSingleton(authState);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      await tester.pumpAndSettle();
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
      ServiceLocator.sl.registerSingleton(authState);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithIcon(FloatingActionButton, Icons.save_rounded),
        findsOneWidget,
      );
    });
    testWidgets('cant edit when not logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      ServiceLocator.setupAuth();
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
      ));
      await tester.pumpAndSettle();
      // find edit button
      expect(
        find.widgetWithIcon(FloatingActionButton, Icons.edit_note),
        findsNothing,
      );
    });
  });
  group('test copy', () {
    testWidgets('copy fields exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final review = testReview();
      final reviewState = ReviewState(mockService, review: review);

      final otherUser = testUser(username: 'otherUser');
      final authState = await loggedInState(username: otherUser.username);
      ServiceLocator.sl.registerSingleton(authState);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      await tester.pumpAndSettle();
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final titleField = find.widgetWithText(TextField, review.story.title);
      expect(titleField, findsOneWidget);
      expect(find.text(review.story.title), findsOneWidget);

      final bodyField = find.bySemanticsLabel('Body Field');
      expect(bodyField, findsOneWidget);
      expect(find.text(''), findsOneWidget);

      expect(find.byType(ReviewEmotionsList), findsNothing);
    });
  });
  group('test edit', () {
    testWidgets('fields exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      ServiceLocator.sl.registerSingleton(authState);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // set to edit mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final titleField = find.widgetWithText(TextField, review.story.title);
      expect(titleField, findsOneWidget);
      expect(find.text(review.story.title), findsOneWidget);

      final bodyField = find.widgetWithText(TextField, review.body!);
      expect(bodyField, findsOneWidget);
      expect(find.text(review.body!), findsOneWidget);

      await tester.enterText(titleField, 'title1');
      await tester.pumpAndSettle();
      expect(find.text('title1'), findsOneWidget);

      await tester.enterText(bodyField, 'body1');
      await tester.pumpAndSettle();
      expect(find.text('body1'), findsOneWidget);
    });
    testWidgets('error message editing on bad info', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final mockService = MockReviewService();
      final review = testReview(slug: '/');
      final reviewState = ReviewState(mockService, review: review);
      final authState = await loggedInState(username: user.username);
      ServiceLocator.sl.registerSingleton(authState);
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
        review.slug,
        review.story,
        review.body,
      )).thenThrow(testApiError(400, 'Cannot be /.'));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Bad Request: Cannot be /.'),
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
      ServiceLocator.sl.registerSingleton(authState);
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
        review.story,
        review.body,
      )).thenAnswer((realInvocation) async => ReviewResp(review: review));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Updated Review'),
        findsOneWidget,
      );
    });
  });
  group('test create', () {
    testWidgets('error message creating on bad info create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);

      ServiceLocator.setupAuth();
      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title Field');
      await tester.enterText(titleField, '/');
      await tester.enterText(find.bySemanticsLabel('Creator Field'), '/');

      final bodyField = find.bySemanticsLabel('Body Field');
      await tester.enterText(bodyField, 'body');
      await tester.pumpAndSettle();

      when(mockService.create(
        errorStory(),
        'body',
      )).thenThrow(testApiError(400, 'Cannot be /.'));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      verify(mockService.create(errorStory(), 'body'));
      expect(
        find.widgetWithText(SnackBar, 'Bad Request: Cannot be /.'),
        findsOneWidget,
      );
    });
    testWidgets('create', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final reviewState = ReviewState(mockService);
      ServiceLocator.setupAuth();
      final review = testReview();

      await tester
          .pumpWidget(wrapWithMaterial(const ReviewWidget(), reviewState));
      await tester.pumpAndSettle();

      final titleField = find.bySemanticsLabel('Title Field');
      await tester.enterText(titleField, review.story.title);

      final creatorField = find.bySemanticsLabel('Creator Field');
      await tester.enterText(creatorField, review.story.creator);

      final bodyField = find.bySemanticsLabel('Body Field');
      await tester.enterText(bodyField, review.body!);
      await tester.pumpAndSettle();

      when(mockService.create(
        Story(
          title: review.story.title,
          medium: Medium.mediumDefault,
          creator: review.story.creator,
        ),
        review.body,
      )).thenAnswer((realInvocation) async => ReviewResp(review: review));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.widgetWithText(SnackBar, 'Updated Review'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });
  });
  group('test delete', () {
    testWidgets('can delete when logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      final reviewState = ReviewState(ReviewService(), review: review);
      final authState = await loggedInState(username: user.username);
      ServiceLocator.sl.registerSingleton(authState);
      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      // find menu button
      final menuButton = find.byIcon(Icons.adaptive.more);
      expect(menuButton, findsOneWidget);
      await tester.pumpAndSettle();
    });
    testWidgets('cant delete when not logged in', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review = testReview(username: user.username);

      ServiceLocator.setupAuth();
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
      await tester.pumpAndSettle();
    });
    testWidgets('delete', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockReviewService();
      final user = testUser();
      final review = testReview();
      final reviewState = ReviewState(mockService, review: review);
      final authState = await loggedInState(username: user.username);
      ServiceLocator.sl.registerSingleton(authState);

      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
        authState: authState,
      ));
      await tester.pumpAndSettle();

      when(mockService.delete(review.user.username, review.slug))
          .thenAnswer((realInvocation) async => {});

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
        find.widgetWithText(SnackBar, 'Deleted Review'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });
  });
  group('test load', () {
    testWidgets('loads data from api and displays', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final user = testUser();
      final review =
          testReview(username: user.username, emotions: [testReviewEmotion()]);
      final mockService = MockReviewService();

      when(mockService.read(review.user.username, review.slug))
          .thenAnswer((realInvocation) async => ReviewResp(review: review));

      final reviewState = ReviewState(
        mockService,
        path: ReviewRoutePath(
          review.slug,
          user.username,
        ),
      );

      await tester.pumpWidget(wrapWithMaterial(
        const ReviewWidget(),
        reviewState,
      ));
      await tester.pumpAndSettle();

      verify(mockService.read(review.user.username, review.slug));
      // find menu button
      expect(find.text(review.story.title), findsOneWidget);
      final re = review.emotions.first;
      expect(find.text(re.notes!, findRichText: true), findsOneWidget);
      expect(find.text(re.emotion.name), findsOneWidget);
      expect(find.text('${re.position}%'), findsOneWidget);
      expect(find.text(review.body!), findsOneWidget);
    });
  });
}
