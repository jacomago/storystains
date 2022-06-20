import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/features/review_emotion/review_emotion_edit.dart';

import 'dart:io' as io;
import '../../common/image_mock_http.dart';
import '../../model/emotion.dart';
import '../../model/review.dart';

Widget wrapWithMaterial(
  Widget w,
  EmotionsState? emotionsState,
  ReviewEmotionState? reviewEmotionState,
  ReviewState? reviewState,
) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EmotionsState>(
          create: (_) => emotionsState ?? EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider<ReviewEmotionState>(
          create: (_) =>
              reviewEmotionState ??
              ReviewEmotionState(
                ReviewEmotionService(),
                emotion: testEmotion(),
              ),
        ),
        ChangeNotifierProvider<ReviewState>(
          create: (_) =>
              reviewState ??
              ReviewState(
                ReviewService(),
                testReview(),
              ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: w,
        ),
      ),
    );

@GenerateMocks([ReviewEmotionService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("Edit review emotion", () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets('minimal data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        wrapWithMaterial(
          ReviewEmotionEdit(
            // ignore: no-empty-block
            cancelHandler: () {},
            // ignore: no-empty-block
            okHandler: (_) {},
          ),
          null,
          null,
          null,
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}

// TODO create
// TODO update
// TODO ok
// TODO cancel
// TODO fail