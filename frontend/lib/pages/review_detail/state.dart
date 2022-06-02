import 'package:get/get.dart';
import '../../model/entity/review.dart';

class ReviewDetailState {
  var review = Rxn<Review>();

  String? get reviewTitle => review.value?.title;

  String? get body => review.value?.body;

}
