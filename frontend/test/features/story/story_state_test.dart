import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/story/story.dart';
import 'package:mockito/annotations.dart';

import '../../common/errors.dart';
import 'story.dart';
import 'story_state_test.mocks.dart';

@GenerateMocks([StoryService])
void main() {
  setUp(() => {WidgetsFlutterBinding.ensureInitialized()});
  group("create", () {
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

      when(mockService.create(Story(
        title: "",
        medium: Medium.mediumDefault,
        creator: "",
      ))).thenThrow(testApiError(400, "Cannot be empty."));

      await storyState.update();

      verify(mockService.create(Story(
        title: "",
        medium: Medium.mediumDefault,
        creator: "",
      )));
      expect(storyState.isUpdated, false);
      expect(storyState.error, "Bad Request: Cannot be empty.");
    });

    test('error message on unauthorised info', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockStoryService();
      final storyState = StoryState(mockService);

      when(mockService.create(Story(
        title: "",
        medium: Medium.mediumDefault,
        creator: "",
      ))).thenThrow(testApiError(401, "User not logged in."));

      await storyState.update();

      verify(mockService.create(Story(
        title: "",
        medium: Medium.mediumDefault,
        creator: "",
      )));
      expect(storyState.isUpdated, false);
      expect(storyState.error, "Unauthorised: User not logged in.");
    });
  });
}
