import 'package:get/get.dart';

import 'logic.dart';

class ReviewPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewPostLogic());
  }
}
