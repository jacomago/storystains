
import 'package:dio/dio.dart';
import 'package:storystains/data/network/dio_manager.dart';
import 'package:storystains/data/network/rest_client.dart';
import 'package:storystains/model/req/add_user.dart';
import 'package:storystains/model/req/create_review.dart';

import '../../common/constant/app_config.dart';
import '../../model/req/login.dart';

part 'api_exception.dart';

class Api {
  static final DioManager dioManager = DioManager();

  static final RestClient _restClient =
      RestClient(dioManager.dio, baseUrl: AppConfig.baseUrl);

  static Future register(AddUser addUser) async {
    return await _restClient.addUser(addUser);
  }

  static Future login(Login loginUser) async {
    return await _restClient.loginUser(loginUser);
  }

  static Future createReview(CreateReview review) async {
    return await _restClient.createReview(review);
  }

  static Future updateReview(String slug, CreateReview review) async {
    return await _restClient.updateReview(slug, review);
  }

  static Future readReview(String slug) async {
    return await _restClient.readReview(slug);
  }

  static Future deleteReview(String slug) async {
    return await _restClient.deleteReview(slug);
  }

  static Future reviews(
      [String query = "", int limit = 10, int offset = 0]) async {
    return await _restClient.getReviews(limit: limit, offset: offset);
  }
}
