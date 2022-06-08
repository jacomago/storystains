import '../../data/network/api.dart';
import '../../model/entity/review.dart';

class ReviewsService {
  Future<List<Review>?> fetch([String? query, int? offset]) async {
    try {
      final res = await Api.reviews();

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
