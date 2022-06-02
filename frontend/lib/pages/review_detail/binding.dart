import 'package:get/get.dart';

import 'logic.dart';

class ReviewDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewDetailLogic(), tag: Get.arguments.toString());
  }
}
