import 'package:get/get.dart';

import 'logic.dart';

class ReviewEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewEditLogic());
  }
}
