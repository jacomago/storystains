import 'package:storystains/data/network/api.dart';

import '../../models/review.dart';

class ReviewService {
  Future add(EditReview review) async {
    return await ReviewApi.add(review);
  }

  Future update(EditReview review) async {
    return await ReviewApi.update(review);
  }

}
