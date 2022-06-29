// Mocks generated by Mockito 5.2.0 from annotations
// in storystains/test/features/review_emotion/review_emotion_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:storystains/features/review/review_model.dart' as _i4;
import 'package:storystains/features/review_emotion/review_emotion_model.dart'
    as _i5;
import 'package:storystains/features/review_emotion/review_emotion_service.dart'
    as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [ReviewEmotionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockReviewEmotionService extends _i1.Mock
    implements _i2.ReviewEmotionService {
  MockReviewEmotionService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<dynamic> create(
          _i4.Review? review, _i5.ReviewEmotion? reviewEmotion) =>
      (super.noSuchMethod(Invocation.method(#create, [review, reviewEmotion]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> update(_i4.Review? review, int? position,
          _i5.ReviewEmotion? reviewEmotion) =>
      (super.noSuchMethod(
          Invocation.method(#update, [review, position, reviewEmotion]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> read(String? username, String? slug, int? position) =>
      (super.noSuchMethod(Invocation.method(#read, [username, slug, position]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> delete(_i4.Review? review, int? position) =>
      (super.noSuchMethod(Invocation.method(#delete, [review, position]),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
}
