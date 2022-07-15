import '../../common/constant/app_config.dart';
import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import '../review/review_model.dart';
import 'reviews_model.dart';

/// Wrapper around [RestClient] methods on List of [Review]
class ReviewsService {
  /// Wrapper around [RestClient.getReviews]
  Future<List<Review>?> fetch({ReviewQuery? query, int offset = 0}) async {
    final res = await ServiceLocator.sl.get<RestClient>().getReviews(
          limit: AppConfig.defaultLimit,
          offset: offset,
          title: query?.storyQuery.title,
          medium: query?.storyQuery.medium?.name,
          creator: query?.storyQuery.creator,
          username: query?.username,
        );

    return res.reviews;
  }
}
