import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:mockito/annotations.dart';

import 'dart:io' as io;
import '../../common/image_mock_http.dart';
import 'emotion.dart';
import 'emotions_test.mocks.dart';

@GenerateMocks([EmotionsService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    // Only needs to be done once since the HttpClient generated
    // by this override is cached as a static singleton.
    io.HttpOverrides.global = TestHttpOverrides();
  });
  group("emotions state tests", () {
    test('init test', () async {
      SharedPreferences.setMockInitialValues({});
      final emotion = testEmotion();
      final emotionsResp = EmotionsResp(emotions: [emotion]);

      final mockService = MockEmotionsService();
      when(mockService.fetch())
          .thenAnswer((realInvocation) async => emotionsResp.emotions);

      final emotionState = EmotionsState(mockService);

      verify(mockService.fetch());
      expect(emotionState.isEmpty, false);
    });
    test('init null test', () async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockEmotionsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => null);

      final emotionState = EmotionsState(mockService);

      verify(mockService.fetch());
      expect(emotionState.isEmpty, false);
    });
    test('init test', () async {
      SharedPreferences.setMockInitialValues({});

      final List<Emotion> emotions = List.generate(
        2,
        (index) => testEmotion(name: "name$index"),
      );

      final mockService = MockEmotionsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => emotions);
      when(mockService.fetch()).thenAnswer((realInvocation) async => emotions);

      final emotionState = EmotionsState(mockService);

      verify(mockService.fetch());
      expect(emotionState.isEmpty, false);

      // assert init finished
      await emotionState.initDone;
      expect(emotionState.count, 2);
    });
  });
}
