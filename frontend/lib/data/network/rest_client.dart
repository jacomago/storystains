import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' as retrofit;

import '../../common/constant/app_config.dart';
import '../../model/req/add_user.dart';
import '../../model/req/create_review.dart';
import '../../model/req/login.dart';
import '../../model/resp/review_resp.dart';
import '../../model/resp/reviews_resp.dart';
import '../../model/resp/user_resp.dart';

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

  @retrofit.PUT("/reviews/{slug}")
  Future<ReviewResp> updateReview(@retrofit.Path() String slug,
      @retrofit.Body() CreateReview updatedReview);

  // login user in database
  @retrofit.POST("/login")
  Future<UserResp> loginUser(@retrofit.Body() Login login);

  // get reviews
  @retrofit.GET("/reviews")
  Future<ReviewsResp> getReviews({
    @retrofit.Query("limit") int limit = 10,
    @retrofit.Query("offset") int offset = 0,
  });

  //get current user
  @retrofit.GET("user")
  Future<UserResp> getCurrentUser();
}
