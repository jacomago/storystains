import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/reviews/reviews_model.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/features/reviews/reviews_state.dart';
import 'package:storystains/features/story/story.dart';
import 'package:storystains/pages/story_filter_page.dart';

import '../features/review/review.dart';
import '../features/story/story.dart';
import 'story_filter_page_test.mocks.dart';

Widget wrapWithMaterial(
  Widget w,
  ReviewsState reviewsState,
  StoryState storyState,
) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewsState>(
          create: (_) => reviewsState,
        ),
        ChangeNotifierProvider<AuthState>(
          create: (_) => AuthState(AuthService()),
        ),
        ChangeNotifierProvider<StoryState>(
          create: (_) => storyState,
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
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([ReviewsService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    ServiceLocator.setup();
  });
  tearDown(ServiceLocator.sl.reset);
  group('Story Filter Widget test', () {
    testWidgets('init null query', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final review = testReview(slug: 'randomtitle');
      final mockService = MockReviewsService();
      when(mockService.fetch()).thenAnswer(
        (realInvocation) async => [
          review,
        ],
      );
      when(mockService.fetch(offset: AppConfig.defaultLimit))
          .thenAnswer((realInvocation) async => []);

      final reviewsState = ReviewsState(
        mockService,
      );

      await tester.pumpWidget(wrapWithMaterial(
        const StoryFilter(),
        reviewsState,
        StoryState(StoryService()),
      ));
      await tester.pumpAndSettle();

      verify(mockService.fetch(offset: AppConfig.defaultLimit));

      expect(find.text(review.story.title), findsOneWidget);
      expect(find.text('by ${review.story.creator}'), findsOneWidget);
      expect(find.text(review.story.medium.name), findsOneWidget);
      expect(find.text('@${review.user.username}'), findsOneWidget);
    });
    testWidgets('init query', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final review = testReview(slug: 'randomtitle');
      final mockService = MockReviewsService();
      final storyQuery = testStoryQuery();
      final reviewQuery = ReviewQuery(storyQuery: storyQuery);
      when(mockService.fetch(query: reviewQuery)).thenAnswer(
        (realInvocation) async => [
          review,
        ],
      );
      when(mockService.fetch(
        query: reviewQuery,
        offset: AppConfig.defaultLimit,
      )).thenAnswer((realInvocation) async => []);

      final reviewsState = ReviewsState(
        mockService,
        reviewQuery,
      );

      await tester.pumpWidget(wrapWithMaterial(
        const StoryFilter(),
        reviewsState,
        StoryState(StoryService(), query: storyQuery),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Title Field'), findsOneWidget);
      expect(find.bySemanticsLabel('Creator Field'), findsOneWidget);
      verify(mockService.fetch(
        query: reviewQuery,
        offset: AppConfig.defaultLimit,
      ));

      expect(find.text(review.story.title), findsOneWidget);
      expect(find.text('by ${review.story.creator}'), findsOneWidget);
      expect(find.text(review.story.medium.name), findsOneWidget);
      expect(find.text('@${review.user.username}'), findsOneWidget);
    });
    testWidgets('change query', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final review = testReview(slug: 'randomtitle');
      final mockService = MockReviewsService();
      final storyQuery = testStoryQuery();
      when(mockService.fetch()).thenAnswer(
        (realInvocation) async => [
          review,
        ],
      );
      when(mockService.fetch(
        offset: AppConfig.defaultLimit,
      )).thenAnswer((realInvocation) async => []);

      final reviewsState = ReviewsState(
        mockService,
      );

      await tester.pumpWidget(wrapWithMaterial(
        const StoryFilter(),
        reviewsState,
        StoryState(StoryService(), query: const StoryQuery()),
      ));
      await tester.pumpAndSettle();

      when(mockService.fetch(
        query: ReviewQuery(storyQuery: StoryQuery(title: storyQuery.title)),
      )).thenAnswer((realInvocation) async => []);

      final titleField = find.bySemanticsLabel('Title Field');
      await tester.enterText(titleField, storyQuery.title!);

      verify(mockService.fetch(
        query: ReviewQuery(storyQuery: StoryQuery(title: storyQuery.title)),
      ));

      when(mockService.fetch(
        query: ReviewQuery(
          storyQuery: StoryQuery(
            title: storyQuery.title,
            creator: storyQuery.creator,
          ),
        ),
      )).thenAnswer(
        (realInvocation) async => [
          review,
        ],
      );

      final creatorField = find.bySemanticsLabel('Creator Field');
      await tester.enterText(creatorField, storyQuery.creator!);

      verify(mockService.fetch(
        query: ReviewQuery(
          storyQuery: StoryQuery(
            title: storyQuery.title,
            creator: storyQuery.creator,
          ),
        ),
      ));

      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text(review.story.title), findsOneWidget);
      expect(find.text('by ${review.story.creator}'), findsOneWidget);
      expect(find.text(review.story.medium.name), findsOneWidget);
      expect(find.text('@${review.user.username}'), findsOneWidget);
    });
  });
}
