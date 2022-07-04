import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import 'story.dart';

import 'story_model.dart';

class StoryService {
  Future<WrappedStory> create(Story story) async =>
      await sl.get<RestClient>().createStory(
            WrappedStory(story: story),
          );
}
