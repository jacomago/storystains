import 'package:get/get.dart';
import 'package:storystains/common/util/storage.dart';
import 'package:storystains/common/util/snackbar.dart';

import '../../model/entity/user.dart';
import '../../pages/pages.dart';
import '../constant/app_keys.dart';
import '../http/dio_manager.dart';
import 'init_utils.dart';

class AuthManager {
  User? _loginUser;

  AuthManager() {
    _loginUser = Storage.getJsonObject<User>(
        AppKeys.loginUser, (json) => User.fromJson(json));
  }

  get isLogin => _loginUser != null && _loginUser!.token.isNotEmpty;

  get token => _loginUser?.token;

  User? get user => _loginUser;

  String? get userName => _loginUser?.username;

  login(User user) async {
    _loginUser = user;
    await Storage.setJsonObject(AppKeys.loginUser, user);
  }

  logout(String reason, [bool jumpToHome = false]) async {
    _loginUser = null;
    await Storage.remove(AppKeys.loginUser);
    sl<DioManager>().cancelAll(reason);
    SnackBarUtil.show(reason);
    if (jumpToHome) {
      Get.until((route) => route.settings.name == Pages.home);
    }
  }
}
