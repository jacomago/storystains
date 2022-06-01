import 'package:storystains/data/network/api.dart';

import '../../models/review.dart';

class ReviewService {
  Future add(Review review) async {
    return await ReviewApi.add(review);
  }

  Future update(Review review) async {
    return await ReviewApi.update(review);
  }

  Future delete(Review review) async {
    return await ReviewApi.delete(review);
  }
}
