import 'package:dio/dio.dart';
import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/model/req/add_user.dart';
import 'package:storystains/model/req/create_review.dart';
import 'package:storystains/model/req/login.dart';

part 'api_exception.dart';

class Api {
  static Future register(AddUser addUser) async {
    return await sl.get<RestClient>().addUser(addUser);
  }

  static Future login(Login loginUser) async {
    return await sl.get<RestClient>().loginUser(loginUser);
  }

  static Future createReview(CreateReview review) async {
    return await sl.get<RestClient>().createReview(review);
  }

  static Future updateReview(String slug, CreateReview review) async {
    return await sl.get<RestClient>().updateReview(slug, review);
  }

  static Future readReview(String slug) async {
    return await sl.get<RestClient>().readReview(slug);
  }

  static Future deleteReview(String slug) async {
    return await sl.get<RestClient>().deleteReview(slug);
  }

  static Future reviews(
      {String query = "", int limit = 10, int offset = 0}) async {
    return await sl.get<RestClient>().getReviews(limit: limit, offset: offset);
  }
}
