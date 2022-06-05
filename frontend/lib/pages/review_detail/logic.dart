import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'state.dart';

class ReviewDetailLogic extends GetxController {
  final ReviewDetailState state = ReviewDetailState();

  @override
  void onReady() {
    super.onReady();
    state.review.value = Get.arguments;
  }
}
