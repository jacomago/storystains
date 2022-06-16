import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/model/entity/review_emotion.dart';
import 'package:storystains/model/req/create_review_emotion.dart';

class ReviewEmotionService {
  Future create(String slug, ReviewEmotion reviewEmotion) async {
    return await sl.get<RestClient>().createReviewEmotion(
          slug,
          CreateReviewEmotion(
            reviewEmotion: NewReviewEmotion(
              emotion: reviewEmotion.emotion.name,
              position: reviewEmotion.position,
              notes: reviewEmotion.notes,
            ),
          ),
        );
  }

  Future update(String slug, int position, ReviewEmotion reviewEmotion) async {
    return await sl.get<RestClient>().updateReviewEmotion(
          slug,
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
    String slug,
    int position,
  ) async {
    return await sl.get<RestClient>().readReviewEmotion(slug, position);
  }

  Future delete(
    String slug,
    int position,
  ) async {
    return await sl.get<RestClient>().deleteReviewEmotion(slug, position);
  }
}
