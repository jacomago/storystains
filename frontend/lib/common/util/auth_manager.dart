import 'package:get/get.dart';
import 'package:storystains/common/util/storage.dart';
import 'package:storystains/common/util/snackbar.dart';

import '../../model/entity/user.dart';
import '../../pages/pages.dart';
import '../constant/app_keys.dart';
import '../http/dio_manager.dart';
class AuthManager {
  static User? _loginUser;

  static init() async {
    _loginUser = Storage.getJsonObject<User>(
        AppKeys.loginUser, (json) => User.fromJson(json));
  }

  static get isLogin => _loginUser != null && _loginUser!.token.isNotEmpty;

  static get token => _loginUser?.token;

  static User? get user => _loginUser;

  static String? get userName => _loginUser?.username;

  static login(User user) async {
    _loginUser = user;
    await Storage.setJsonObject(AppKeys.loginUser, user);
  }

  static logout(String reason, [bool jumpToHome = false]) async {
    _loginUser = null;
    await Storage.remove(AppKeys.loginUser);
    DioManager.cancelAll(reason);
    ToastUtils.show(reason);
    if (jumpToHome) {
      Get.until((route) => route.settings.name == Pages.home);
    }
  }
}
