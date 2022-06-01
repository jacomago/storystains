part of 'api.dart';

class ReviewApi {
  static final ApiHandler _handler = ApiHandler();

  static Future reviews([int? limit, int? offset]) async {
    String url = '$reviewsUrl?';
    if (limit is int && limit != defaultLimit) url += 'limit=$limit';
    if (offset is int && offset > 0) url += 'offset=$offset';
    return await _handler.get(url);
  }

  static Future add(Review review) async {
    String url = '$reviewsUrl/$review.slug';
    return await _handler.post(url, review.toJson());
  }

  static Future update(Review review) async {
    String url = '$reviewsUrl/$review.slug';
    return await _handler.put(url, review.toJson());
  }

  static Future delete(Review review) async {
    String url = '$reviewsUrl/$review.slug';
    return await _handler.delete(url);
  }
}
