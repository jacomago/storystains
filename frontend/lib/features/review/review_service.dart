import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/story/story.dart';

import 'review_model.dart';

class ReviewService {
  Future<ReviewResp> create(Story story, String body) async {
    return await sl.get<RestClient>().createReview(
          CreateReview(
            review: NewReview(
              story: story,
              body: body,
            ),
          ),
        );
  }

  Future<ReviewResp> update(
      String username, String slug, Story story, String body) async {
    return await sl.get<RestClient>().updateReview(
          username,
          slug,
          CreateReview(
            review: NewReview(
              story: story,
              body: body,
            ),
          ),
        );
  }

  Future<ReviewResp> read(String username, String slug) async {
    return await sl.get<RestClient>().readReview(username, slug);
  }

  Future<void> delete(String username, String slug) async {
    return await sl.get<RestClient>().deleteReview(username, slug);
  }
}
