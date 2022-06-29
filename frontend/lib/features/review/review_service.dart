import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';

import 'review_model.dart';

class ReviewService {
  Future create(String title, String body) async {
    return await sl.get<RestClient>().createReview(
          CreateReview(review: NewReview(title: title, body: body)),
        );
  }

  Future update(String username, String slug, String title, String body) async {
    return await sl.get<RestClient>().updateReview(
          username,
          slug,
          CreateReview(review: NewReview(title: title, body: body)),
        );
  }

  Future read(String username, String slug) async {
    return await sl.get<RestClient>().readReview(username, slug);
  }

  Future delete(String username, String slug) async {
    return await sl.get<RestClient>().deleteReview(username, slug);
  }
}
