import 'package:storystains/model/req/create_review.dart';

import '../../data/network/api.dart';
import '../../model/req/add_user.dart';
import '../../model/req/login.dart';

class ReviewService {
  Future create(String title, String body) async {
    return await Api.createReview(
        CreateReview(review: NewReview(title: title, body: body)));
  }

  Future update(String slug, String title, String body) async {
    return await Api.updateReview(
        slug, CreateReview(review: NewReview(title: title, body: body)));
  }
  Future read(String slug) async {
    return await Api.readReview(
        slug);
  }
}
