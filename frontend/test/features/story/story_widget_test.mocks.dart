// Mocks generated by Mockito 5.2.0 from annotations
// in storystains/test/features/story/story_widget_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:storystains/features/mediums/medium_model.dart' as _i5;
import 'package:storystains/features/mediums/medium_service.dart' as _i3;
import 'package:storystains/features/story/story.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeWrappedStory_0 extends _i1.Fake implements _i2.WrappedStory {}

class _FakeStoriesResp_1 extends _i1.Fake implements _i2.StoriesResp {}

/// A class which mocks [MediumsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMediumsService extends _i1.Mock implements _i3.MediumsService {
  MockMediumsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<List<_i5.Medium>?> fetch() =>
      (super.noSuchMethod(Invocation.method(#fetch, []),
              returnValue: Future<List<_i5.Medium>?>.value())
          as _i4.Future<List<_i5.Medium>?>);
}

/// A class which mocks [StoryService].
///
/// See the documentation for Mockito's code generation for more information.
class MockStoryService extends _i1.Mock implements _i2.StoryService {
  MockStoryService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.WrappedStory> create(_i2.Story? story) => (super.noSuchMethod(
          Invocation.method(#create, [story]),
          returnValue: Future<_i2.WrappedStory>.value(_FakeWrappedStory_0()))
      as _i4.Future<_i2.WrappedStory>);
  @override
  _i4.Future<_i2.StoriesResp> search(_i2.StoryQuery? story) =>
      (super.noSuchMethod(Invocation.method(#search, [story]),
              returnValue: Future<_i2.StoriesResp>.value(_FakeStoriesResp_1()))
          as _i4.Future<_i2.StoriesResp>);
}
