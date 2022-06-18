import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/widget/emotion_picker.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/model/entity/emotion.dart';

import 'dart:io' as io;
import '../image_mock_http.dart';
import 'emotion_picker_test.mocks.dart';

Widget wrapWithMaterial(Widget w, EmotionsState? emotionsState) =>
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
  group("Emotions Picker", () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets('no data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        wrapWithMaterial(
          EmotionDialog(
            initialEmotion: Emotion(
              description: "",
              iconUrl: "/img",
              name: "Anger",
            ),
          ),
          null,
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('Input emotions', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final list = [
        Emotion(name: "Anger", iconUrl: "/img", description: "description"),
        Emotion(name: "name", iconUrl: "/iconUrl", description: "description"),
      ];

      final emotionService = MockEmotionsService();
      when(emotionService.fetch()).thenAnswer((realInvocation) async => list);

      final emotionsState = EmotionsState(emotionService);
      
      await tester.pumpWidget(
        wrapWithMaterial(
          EmotionDialog(
            initialEmotion: Emotion(
              description: "",
              iconUrl: "/img",
              name: "Anger",
            ),
          ),
          emotionsState,
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('Input emotions are visible', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final list = [
        Emotion(name: "Anger", iconUrl: "/img", description: "description"),
        Emotion(name: "name", iconUrl: "/iconUrl", description: "description"),
      ];

      final emotionService = MockEmotionsService();
      when(emotionService.fetch()).thenAnswer((realInvocation) async => list);

      final emotionsState = EmotionsState(emotionService);
      
      await tester.pumpWidget(
        wrapWithMaterial(
          EmotionDialog(
            initialEmotion: Emotion(
              description: "",
              iconUrl: "/img",
              name: "Anger",
            ),
          ),
          emotionsState,
        ),
      );
      await tester.pumpAndSettle();


      for (Emotion e in list) {
        expect(find.text(e.name), findsOneWidget);
      }
    });
  });
}
