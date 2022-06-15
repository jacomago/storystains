import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/model/req/create_review.dart';

class ReviewService {
  Future create(String title, String body) async {
    return await sl.get<RestClient>().createReview(
        CreateReview(review: NewReview(title: title, body: body)));
  }

  Future update(String slug, String title, String body) async {
    return await sl.get<RestClient>().updateReview(
        slug, CreateReview(review: NewReview(title: title, body: body)));
  }

  Future read(String slug) async {
    return await sl.get<RestClient>().readReview(slug);
  }

  Future delete(String slug) async {
    return await sl.get<RestClient>().deleteReview(slug);
  }
}
