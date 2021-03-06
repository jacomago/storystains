import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/story/story.dart';

import '../../common/errors.dart';
import 'story.dart';
import 'story_state_test.mocks.dart';

@GenerateMocks([StoryService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group('create', () {
    test('After create in isUpdated', () async {
      SharedPreferences.setMockInitialValues({});
      final story = testStory();
      final storyResp = WrappedStory(story: story);

      final mockService = MockStoryService();
      final storyState = StoryState(mockService);

      when(mockService.create(story))
          .thenAnswer((realInvocation) async => storyResp);

      storyState.titleController.text = story.title;
      storyState.creatorController.text = story.creator;
      storyState.mediumController.value = story.medium;
      await storyState.update();

      verify(mockService.create(story));
      expect(storyState.isUpdated, true);
    });

    test('error message on bad info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockStoryService();
      final storyState = StoryState(mockService);

      when(mockService.create(emptyStory()))
          .thenThrow(testApiError(400, 'Cannot be empty.'));

      await storyState.update();

      verify(mockService.create(emptyStory()));
      expect(storyState.isUpdated, false);
      expect(storyState.error, 'Bad Request: Cannot be empty.');
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockStoryService();
      final storyState = StoryState(mockService);

      when(mockService.create(emptyStory()))
          .thenThrow(testApiError(401, 'User not logged in.'));

      await storyState.update();

      verify(mockService.create(emptyStory()));
      expect(storyState.isUpdated, false);
      expect(storyState.error, 'Unauthorised: User not logged in.');
    });
  });
  group('search', () {
    test('Search returns empty', () async {
      SharedPreferences.setMockInitialValues({});
      final storiesResp = StoriesResp(stories: []);

      final mockService = MockStoryService();
      final storyState = StoryState(mockService, story: testStory());

      when(mockService.search(testStoryQuery()))
          .thenAnswer((realInvocation) async => storiesResp);

      expectLater(
        storyState.searchResults.stream,
        emitsInOrder(
          [],
        ),
      );
      await storyState.search();
      verify(mockService.search(testStoryQuery()));
    });
    test('Search empty does not search', () async {
      SharedPreferences.setMockInitialValues({});
      final storiesResp = StoriesResp(stories: []);

      final mockService = MockStoryService();
      final storyState = StoryState(mockService);

      when(mockService.search(const StoryQuery()))
          .thenAnswer((realInvocation) async => storiesResp);

      await storyState.search();
      verifyNever(mockService.search(testStoryQuery()));
    });

    test('Search returns error', () async {
      SharedPreferences.setMockInitialValues({});

      final mockService = MockStoryService();
      final storyState = StoryState(mockService, story: testStory());

      when(mockService.search(testStoryQuery()))
          .thenThrow(testApiError(400, 'Bad'));

      await storyState.search();
      verify(mockService.search(testStoryQuery()));

      expect(storyState.error, 'Bad Request: Bad');
    });

    test('Search returns list', () async {
      SharedPreferences.setMockInitialValues({});
      final storiesResp = StoriesResp(stories: [
        testStory(title: 'Dune'),
        testStory(title: 'Star Wars'),
      ]);

      final mockService = MockStoryService();
      final storyState = StoryState(mockService, story: testStory());

      when(mockService.search(testStoryQuery()))
          .thenAnswer((realInvocation) async => storiesResp);
      expectLater(
        storyState.searchResults.stream,
        emitsInOrder(
          [storiesResp.stories],
        ),
      );
      await storyState.search();
      verify(mockService.search(testStoryQuery()));
    });
  });
}
