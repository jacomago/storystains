import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import '../review/review_model.dart';
import 'review_emotion_model.dart';

/// Wrapper around [RestClient] methods on a [ReviewEmotion]
class ReviewEmotionService {
  /// Wrapper around [RestClient.createReviewEmotion]
  Future<ReviewEmotionResp> create(
    Review review,
    ReviewEmotion reviewEmotion,
  ) async =>
      await ServiceLocator.sl.get<RestClient>().createReviewEmotion(
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

  /// Wrapper around [RestClient.updateReviewEmotion]
  Future<ReviewEmotionResp> update(
    Review review,
    int position,
    ReviewEmotion reviewEmotion,
  ) async =>
      await ServiceLocator.sl.get<RestClient>().updateReviewEmotion(
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

  /// Wrapper around [RestClient.readReviewEmotion]
  Future<ReviewEmotionResp> read(
    String username,
    String slug,
    int position,
  ) async =>
      await ServiceLocator.sl
          .get<RestClient>()
          .readReviewEmotion(username, slug, position);

  /// Wrapper around [RestClient.deleteReviewEmotion]
  Future<void> delete(
    Review review,
    int position,
  ) async =>
      await ServiceLocator.sl
          .get<RestClient>()
          .deleteReviewEmotion(review.user.username, review.slug, position);
}
