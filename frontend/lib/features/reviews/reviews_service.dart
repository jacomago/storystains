import 'package:storystains/model/resp/reviews_resp.dart';

import '../../data/network/api.dart';
import '../../model/entity/review.dart';

class ReviewsService {
  Future<List<Review>?> fetch({String query = "", int offset = 0}) async {
    try {
      final res = await Api.reviews(query: query, offset: offset);

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
