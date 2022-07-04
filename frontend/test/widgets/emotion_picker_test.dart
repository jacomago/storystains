import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/emotions/emotion.dart';

import '../common/image_mock_http.dart';
import '../features/emotions/emotion.dart';
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
  tearDown(ServiceLocator.sl.reset);
  group('Emotions Picker', () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
      ServiceLocator.setup();
    });

    testWidgets('no data smoke test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        wrapWithMaterial(
          EmotionDialog(
            initialEmotion: testEmotion(),
          ),
          null,
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('Input emotions', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final initEmotion = testEmotion();
      final list = [
        initEmotion,
        testEmotion(name: '2'),
      ];

      final emotionService = MockEmotionsService();
      when(emotionService.fetch()).thenAnswer((realInvocation) async => list);

      final emotionsState = EmotionsState(emotionService);
      await tester.pumpWidget(
        wrapWithMaterial(
          EmotionDialog(
            initialEmotion: initEmotion,
          ),
          emotionsState,
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('Input emotions are visible', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final initEmotion = testEmotion();
      final list = [
        initEmotion,
        testEmotion(name: '2'),
      ];

      final emotionService = MockEmotionsService();
      when(emotionService.fetch()).thenAnswer((realInvocation) async => list);

      final emotionsState = EmotionsState(emotionService);

      await tester.pumpWidget(
        wrapWithMaterial(
          EmotionDialog(
            initialEmotion: initEmotion,
          ),
          emotionsState,
        ),
      );
      await tester.pumpAndSettle();

      for (var e in list) {
        expect(find.text(e.name), findsOneWidget);
      }
    });
  });
}
