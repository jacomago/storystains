import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' as retrofit;
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/features/auth/auth_model.dart';
import 'package:storystains/features/emotions/emotion_model.dart';
import 'package:storystains/features/mediums/mediums.dart';
import 'package:storystains/features/review/review_model.dart';
import 'package:storystains/features/review_emotion/review_emotion_model.dart';
import 'package:storystains/features/reviews/reviews_model.dart';
import 'package:storystains/features/story/story.dart';
part 'rest_client.g.dart';

@retrofit.RestApi(baseUrl: AppConfig.baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // add new user in database
  @retrofit.POST("/signup")
  Future<UserResp> addUser(@retrofit.Body() AddUser addUser);

  // add new review in database
  @retrofit.POST("/reviews")
  Future<ReviewResp> createReview(@retrofit.Body() CreateReview newReview);

  // add new story in database
  @retrofit.POST("/stories")
  Future<StoryResp> createStory(@retrofit.Body() CreateStory newStory);

  @retrofit.PUT("/reviews/{username}/{slug}")
  Future<ReviewResp> updateReview(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Body() CreateReview updatedReview,
  );

  @retrofit.GET("/reviews/{username}/{slug}")
  Future<ReviewResp> readReview(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
  );

  @retrofit.DELETE("/reviews/{username}/{slug}")
  Future<void> deleteReview(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
  );

  // add new review in database
  @retrofit.POST("/reviews/{username}/{slug}/emotions")
  Future<ReviewEmotionResp> createReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Body() CreateReviewEmotion newReviewEmotion,
  );

  @retrofit.PUT("/reviews/{username}/{slug}/emotions/{position}")
  Future<ReviewEmotionResp> updateReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Path() int position,
    @retrofit.Body() CreateReviewEmotion updatedReviewEmotion,
  );

  @retrofit.GET("/reviews/{username}/{slug}/emotions/{position}")
  Future<ReviewEmotionResp> readReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Path() int position,
  );

  @retrofit.DELETE("/reviews/{username}/{slug}/emotions/{position}")
  Future<void> deleteReviewEmotion(
    @retrofit.Path() String username,
    @retrofit.Path() String slug,
    @retrofit.Path() int position,
  );

  // login user in database
  @retrofit.POST("/login")
  Future<UserResp> loginUser(@retrofit.Body() Login login);

  // login user in database
  @retrofit.DELETE("/users")
  Future<void> deleteUser();

  // get reviews
  @retrofit.GET("/reviews")
  Future<ReviewsResp> getReviews({
    @retrofit.Query("limit") int limit = 10,
    @retrofit.Query("offset") int offset = 0,
  });

  // get emotions
  @retrofit.GET("/emotions")
  Future<EmotionsResp> getEmotions();

  // get emotions
  @retrofit.GET("/mediums")
  Future<MediumsResp> getMediums();

  //get current user
  @retrofit.GET("user")
  Future<UserResp> getCurrentUser();
}
