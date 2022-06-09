import 'package:storystains/model/resp/reviews_resp.dart';

import '../../data/network/api.dart';
import '../../model/entity/review.dart';

class ReviewsService {
  Future<List<Review>?> fetch([String? query, int? offset]) async {
    try {
      final res = await Api.reviews();

      if (res is ReviewsResp) {
        final data = res.reviews;

        return data;
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
