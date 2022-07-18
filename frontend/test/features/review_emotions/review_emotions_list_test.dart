import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/common/widget/emotion_edit.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/features/review_emotion/review_emotion_edit.dart';
import 'package:storystains/features/review_emotion/review_emotion_model.dart';
import 'package:storystains/features/review_emotions/review_emotions.dart';

import '../../common/image_mock_http.dart';
import '../emotions/emotion.dart';
import '../review/review.dart';
import '../review_emotion/review_emotion.dart';
import 'review_emotions_list_test.mocks.dart';

Widget wrapWithMaterial(
  Widget w,
  ReviewEmotionsState reviewEmotionsState, {
  EmotionsState? emotionsState,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewEmotionsState>(
          create: (_) => reviewEmotionsState,
        ),
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => emotionsState ?? EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider<ReviewState>(
          create: (_) => ReviewState(
            ReviewService(),
            review: testReview(),
          ),
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

@GenerateMocks([EmotionsService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group('Review Emotions list', () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
      ServiceLocator.setup();
    });
    tearDown(ServiceLocator.sl.reset);

    testWidgets('no data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final reviewEmotionsState = ReviewEmotionsState([]);
      await tester.pumpWidget(
        wrapWithMaterial(const ReviewEmotionsList(), reviewEmotionsState),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('load list', (tester) async {
      final list = [
        const ReviewEmotion(
          notes: 'notes0',
          emotion: Emotion(
            name: 'Anger',
            iconUrl: '/url1',
            description: 'description1',
            joy: 0,
            sadness: 0,
            anger: 2,
            disgust: 0,
            surprise: 0,
            fear: 0,
          ),
          position: 0,
        ),
        const ReviewEmotion(
          notes: 'notes1',
          emotion: Emotion(
            name: 'Joy1',
            iconUrl: '/url2',
            description: 'description2',
            joy: 3,
            sadness: 0,
            anger: 0,
            disgust: 0,
            surprise: 0,
            fear: 0,
          ),
          position: 1,
        ),
        const ReviewEmotion(
          notes: 'notes2',
          emotion: Emotion(
            name: 'Anger2',
            iconUrl: '/url3',
            description: 'description3',
            joy: 0,
            sadness: 0,
            anger: 3,
            disgust: 0,
            surprise: 0,
            fear: 0,
          ),
          position: 2,
        ),
      ];
      final reviewEmotionsState = ReviewEmotionsState(list);
      // in a scroll for the scolling list part
      await tester.pumpWidget(
        wrapWithMaterial(
          const SingleChildScrollView(child: ReviewEmotionsList()),
          reviewEmotionsState,
        ),
      );
      await tester.pumpAndSettle();

      for (var re in list) {
        expect(find.text(re.notes), findsOneWidget);
        expect(find.text(re.emotion.name), findsOneWidget);
        expect(find.text('Position: ${re.position}%'), findsOneWidget);
      }
    });
    testWidgets('add', (tester) async {
      final reviewEmotionsState = ReviewEmotionsState([]);
      final initEmotion = testEmotion();
      final list = [
        initEmotion,
        testEmotion(name: '2'),
      ];
      final emotionService = MockEmotionsService();
      when(emotionService.fetch()).thenAnswer((realInvocation) async => list);

      final emotionsState = EmotionsState(emotionService);
      // in a scroll for the scolling list part
      await tester.pumpWidget(
        wrapWithMaterial(
          const SingleChildScrollView(child: ReviewEmotionsList()),
          reviewEmotionsState,
          emotionsState: emotionsState,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
      await tester.pump();

      final newWidget = find.byType(GridTile);
      await tester.tap(newWidget.first);
      await tester.pump();

      final reviewEdit = find.byType(ReviewEmotionEdit);
      expect(reviewEdit, findsOneWidget);
    });
    testWidgets('update', (tester) async {
      final initEmotion = testEmotion();
      final emotionList = [
        initEmotion,
        testEmotion(name: '2'),
      ];
      final emotionService = MockEmotionsService();
      when(emotionService.fetch())
          .thenAnswer((realInvocation) async => emotionList);

      final emotionsState = EmotionsState(emotionService);

      final list = [
        testReviewEmotion(emotion: initEmotion),
      ];
      final reviewEmotionsState = ReviewEmotionsState(list);

      // in a scroll for the scolling list part
      await tester.pumpWidget(
        wrapWithMaterial(
          const SingleChildScrollView(child: ReviewEmotionsList()),
          reviewEmotionsState,
          emotionsState: emotionsState,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EmotionEdit).first);
      await tester.pump();

      final newWidget = find.byType(GridTile);
      await tester.tap(newWidget.first);
      await tester.pump();

      final reviewEdit = find.byType(ReviewEmotionEdit);
      expect(reviewEdit, findsOneWidget);
    });
  });
}
