import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' as retrofit;

import '../../../features/auth/auth_model.dart';
import '../../../features/emotions/emotion_model.dart';
import '../../../features/mediums/medium.dart';
import '../../../features/review/review_model.dart';
import '../../../features/review_emotion/review_emotion_model.dart';
import '../../../features/reviews/reviews_model.dart';
import '../../../features/story/story.dart';
import '../../constant/app_config.dart';

part 'rest_client.g.dart';

/// The main rest client for the api
@retrofit.RestApi(baseUrl: AppConfig.baseUrl)
abstract class RestClient {
  /// Factory method to create the rest client
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  /// Add new [Story] via api
  @retrofit.POST('/stories')
  Future<WrappedStory> createStory(@retrofit.Body() WrappedStory newStory);

  /// Get [Story]s from api
  @retrofit.GET('/stories')
  // ignore: long-parameter-list
  Future<StoriesResp> searchStories({
    @retrofit.Query('creator') String? creator,
    @retrofit.Query('medium') String? medium,
    @retrofit.Query('title') String? title,
    @retrofit.Query('limit') int limit = 10,
    @retrofit.Query('offset') int offset = 0,
  });

  /// Add new [Review] via api
  @retrofit.POST('/reviews')
  Future<ReviewResp> createReview(@retrofit.Body() CreateReview newReview);

  /// Update [Review] in api
  @retrofit.PUT('/reviews/{username}/{slug}')
  Future<ReviewResp> updateReview(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Body() CreateReview updatedReview,
  );

  /// Get the info of the [Review]
  @retrofit.GET('/reviews/{username}/{slug}')
  Future<ReviewResp> readReview(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
  );

  /// Delete the [Review]
  @retrofit.DELETE('/reviews/{username}/{slug}')
  Future<void> deleteReview(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
  );

  /// Create new [ReviewEmotion] via the api
  @retrofit.POST('/reviews/{username}/{slug}/emotions')
  Future<ReviewEmotionResp> createReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Body() CreateReviewEmotion newReviewEmotion,
  );

  /// Update the [ReviewEmotion]
  @retrofit.PUT('/reviews/{username}/{slug}/emotions/{position}')
  Future<ReviewEmotionResp> updateReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Path() int position,
    @retrofit.Body() CreateReviewEmotion updatedReviewEmotion,
  );

  /// Get a particular [ReviewEmotion]
  @retrofit.GET('/reviews/{username}/{slug}/emotions/{position}')
  Future<ReviewEmotionResp> readReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Path() int position,
  );

  /// Delete a [ReviewEmotion]
  @retrofit.DELETE('/reviews/{username}/{slug}/emotions/{position}')
  Future<void> deleteReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Path() int position,
  );

  /// Add new [User] via api
  @retrofit.POST('/signup')
  Future<UserResp> addUser(@retrofit.Body() AddUser addUser);

  /// login [User] via api
  @retrofit.POST('/login')
  Future<UserResp> loginUser(@retrofit.Body() AddUser login);

  /// Delete [User] via the api
  @retrofit.DELETE('/users')
  Future<void> deleteUser();

  /// Logout [User] via the api
  @retrofit.POST('/users/logout')
  Future<void> logout();

  /// get current [User] detials
  @retrofit.GET('/user')
  Future<UserResp> getCurrentUser();

  /// Get list of latest [Review]
  @retrofit.GET('/reviews')
  // ignore: long-parameter-list
  Future<ReviewsResp> getReviews({
    @retrofit.Query('username') String? username,
    @retrofit.Query('creator') String? creator,
    @retrofit.Query('medium') String? medium,
    @retrofit.Query('title') String? title,
    @retrofit.Query('limit') int limit = 10,
    @retrofit.Query('offset') int offset = 0,
  });

  /// get all [Emotion]'s available
  @retrofit.GET('/emotions')
  Future<EmotionsResp> getEmotions();

  /// get all [Medium]'s available
  @retrofit.GET('/mediums')
  Future<MediumsResp> getMediums();
}
