import 'package:get/get.dart';

import '../../model/entity/user.dart';

class HomeState {
  var user = Rxn<User>();

  bool get isLogin => user.value?.token.isNotEmpty == true;
}
