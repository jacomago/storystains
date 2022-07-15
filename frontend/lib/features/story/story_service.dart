import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import 'story.dart';

import 'story_model.dart';

/// Wrapper method of [RestClient] use [Story] methods
class StoryService {
  /// Wrapper method of [RestClient.createStory]
  Future<WrappedStory> create(Story story) async =>
      await ServiceLocator.sl.get<RestClient>().createStory(
            WrappedStory(story: story),
          );

  /// Wrapper method of [RestClient.searchStories]
  Future<StoriesResp> search(StoryQuery story) async =>
      await ServiceLocator.sl.get<RestClient>().searchStories(
            title: story.title,
            creator: story.creator,
            medium: story.medium?.name,
          );
}
