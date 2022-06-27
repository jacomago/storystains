import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/model/entity/review.dart';
import 'package:storystains/model/entity/review_emotion.dart';
import 'package:storystains/model/req/create_review_emotion.dart';

class ReviewEmotionService {
  Future create(Review review, ReviewEmotion reviewEmotion) async {
    return await sl.get<RestClient>().createReviewEmotion(
          review.user.username,
          review.slug,
          CreateReviewEmotion(
            reviewEmotion: NewReviewEmotion(
              emotion: reviewEmotion.emotion.name,
              position: reviewEmotion.position,
              notes: reviewEmotion.notes,
            ),
          ),
        );
  }

  Future update(
    Review review,
    int position,
    ReviewEmotion reviewEmotion,
  ) async {
    return await sl.get<RestClient>().updateReviewEmotion(
          review.user.username,
          review.slug,
          position,
          CreateReviewEmotion(
            reviewEmotion: NewReviewEmotion(
              emotion: reviewEmotion.emotion.name,
              position: reviewEmotion.position,
              notes: reviewEmotion.notes,
            ),
          ),
        );
  }

  Future read(
    String username,
    String slug,
    int position,
  ) async {
    return await sl
        .get<RestClient>()
        .readReviewEmotion(username, slug, position);
  }

  Future delete(
    Review review,
    int position,
  ) async {
    return await sl
        .get<RestClient>()
        .deleteReviewEmotion(review.user.username, review.slug, position);
  }
}
