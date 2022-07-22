import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import '../story/story.dart';

import 'review_model.dart';

/// Wrapper around [RestClient] methods on a [Review]
class ReviewService {
  /// Wrapper around [RestClient.createReview]
  Future<ReviewResp> create(Story story, String? body) async =>
      await ServiceLocator.sl.get<RestClient>().createReview(
            CreateReview(
              review: NewReview(
                story: story,
                body: body,
              ),
            ),
          );

  /// Wrapper around [RestClient.updateReview]
  Future<ReviewResp> update(
    String username,
    String slug,
    Story? story,
    String? body,
  ) async =>
      await ServiceLocator.sl.get<RestClient>().updateReview(
            username,
            slug,
            UpdateReviewReq(
              review: UpdateReview(
                story: story,
                body: body,
              ),
            ),
          );

  /// Wrapper around [RestClient.readReview]
  Future<ReviewResp> read(String username, String slug) async =>
      await ServiceLocator.sl.get<RestClient>().readReview(username, slug);

  /// Wrapper around [RestClient.deleteReview]
  Future<void> delete(String username, String slug) async =>
      await ServiceLocator.sl.get<RestClient>().deleteReview(username, slug);
}
