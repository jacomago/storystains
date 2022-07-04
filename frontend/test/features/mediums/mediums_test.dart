import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/mediums/medium.dart';

import '../../common/image_mock_http.dart';
import 'medium.dart';
import 'mediums_test.mocks.dart';

@GenerateMocks([MediumsService])
void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    // Only needs to be done once since the HttpClient generated
    // by this override is cached as a static singleton.
    io.HttpOverrides.global = TestHttpOverrides();
  });
  group('mediums state tests', () {
    test('init test', () async {
      SharedPreferences.setMockInitialValues({});
      final medium = testMedium();
      final mediumsResp = MediumsResp(mediums: [medium]);

      final mockService = MockMediumsService();
      when(mockService.fetch())
          .thenAnswer((realInvocation) async => mediumsResp.mediums);

      final mediumState = MediumsState(mockService);

      verify(mockService.fetch());
      expect(mediumState.isEmpty, false);
    });
    test('init null test', () async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockMediumsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => null);

      final mediumState = MediumsState(mockService);

      verify(mockService.fetch());
      expect(mediumState.isEmpty, false);
    });
    test('init test', () async {
      SharedPreferences.setMockInitialValues({});

      final mediums = List<Medium>.generate(
        2,
        (index) => testMedium(name: 'name$index'),
      );

      final mockService = MockMediumsService();
      when(mockService.fetch()).thenAnswer((realInvocation) async => mediums);
      when(mockService.fetch()).thenAnswer((realInvocation) async => mediums);

      final mediumState = MediumsState(mockService);

      verify(mockService.fetch());
      expect(mediumState.isEmpty, false);

      // assert init finished
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(mediumState.count, 2);
    });
  });
}
