import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/story/story.dart';

import 'story_model.dart';

class StoryService {
  Future create(Story story) async {
    return await sl.get<RestClient>().createStory(
          WrappedStory(story: story),
        );
  }
}
