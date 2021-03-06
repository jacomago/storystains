import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/widget/card_review_emotions.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review_emotion/review_emotion_model.dart';

import '../common/image_mock_http.dart';

Widget wrapWithMaterial(
  Widget w, {
  EmotionsState? emotionsState,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => emotionsState ?? EmotionsState(EmotionsService()),
        ),
      ],
      child: MaterialApp(
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
    });

    testWidgets('no data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        wrapWithMaterial(const CardReviewEmotionsList(items: [])),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('load list', (tester) async {
      final list = <ReviewEmotion>[
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
            joy: 0,
            sadness: 0,
            anger: 3,
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
            anger: 4,
            disgust: 0,
            surprise: 0,
            fear: 0,
          ),
          position: 2,
        ),
      ];
      // in a scroll for the scolling list part
      await tester.pumpWidget(
        wrapWithMaterial(
          SingleChildScrollView(
            child: CardReviewEmotionsList(
              items: list,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var re in list) {
        expect(find.text(re.emotion.name), findsOneWidget);
      }
    });
  });
}
