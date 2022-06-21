import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/widget/card_review_emotions.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review_emotions/review_emotions.dart';
import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';

import 'dart:io' as io;

import '../common/image_mock_http.dart';

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
  group("Review Emotions list", () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets('no data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final reviewEmotionsState = ReviewEmotionsState([]);
      await tester.pumpWidget(
        wrapWithMaterial(const CardReviewEmotionsList(), reviewEmotionsState),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('load list', (tester) async {
      final list = [
        ReviewEmotion(
          notes: "notes0",
          emotion: Emotion(
            name: "Anger",
            iconUrl: "/url1",
            description: "description1",
          ),
          position: 0,
        ),
        ReviewEmotion(
          notes: "notes1",
          emotion: Emotion(
            name: "Joy1",
            iconUrl: "/url2",
            description: "description2",
          ),
          position: 1,
        ),
        ReviewEmotion(
          notes: "notes2",
          emotion: Emotion(
            name: "Anger2",
            iconUrl: "/url3",
            description: "description3",
          ),
          position: 2,
        ),
      ];
      final reviewEmotionsState = ReviewEmotionsState(list);
      // in a scroll for the scolling list part
      await tester.pumpWidget(
        wrapWithMaterial(
          const SingleChildScrollView(child: CardReviewEmotionsList()),
          reviewEmotionsState,
        ),
      );
      await tester.pumpAndSettle();

      for (ReviewEmotion re in list) {
        expect(find.text(re.emotion.name), findsOneWidget);
      }
    });
  });
}