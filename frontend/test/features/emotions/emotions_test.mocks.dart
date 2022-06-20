// Mocks generated by Mockito 5.2.0 from annotations
// in storystains/test/features/emotions/emotions_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:storystains/features/emotions/emotion_service.dart' as _i2;
import 'package:storystains/model/entity/emotion.dart' as _i4;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [EmotionsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockEmotionsService extends _i1.Mock implements _i2.EmotionsService {
  MockEmotionsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.Emotion>?> fetch() =>
      (super.noSuchMethod(Invocation.method(#fetch, []),
              returnValue: Future<List<_i4.Emotion>?>.value())
          as _i3.Future<List<_i4.Emotion>?>);
}
