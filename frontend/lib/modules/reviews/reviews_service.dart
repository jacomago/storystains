import 'package:storystains/data/network/api.dart';
import 'package:storystains/models/review.dart';

class ReviewsService {
  Future<List<Review>?> fetch([int? limit, int? offset]) async {
    try {
      final res = await Api.reviews(limit, offset);

      if (res is Map && res.containsKey('data')) {
        final data = res['data'];

        if (data is List) {
          return data.map<Review>((u) => Review.fromJson(u)).toList();
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
