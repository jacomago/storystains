import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../common/constant/app_config.dart';
import '../../common/util/auth_manager.dart';
import '../../common/util/init_utils.dart';
import '../../common/util/snackbar.dart';
import '../../model/req/add_user.dart';
import '../../model/req/login.dart';
import '../../services/rest_client.dart';
import 'state.dart';

class LoginOrRegisterLogic extends GetxController {
  final LoginOrRegisterState state = LoginOrRegisterState();

  final passwordController = TextEditingController();

  final nameController = TextEditingController();

  void signIn() async {
    try {
      final userResp = await sl<RestClient>().loginUser(Login(
        user: LoginUser(
          username: nameController.value.text,
          password: passwordController.value.text,
        ),
      ));
      sl<AuthManager>().login(userResp.user);
      Get.back(result: userResp.user);
    } catch (e) {
      SnackBarUtil.showError(e);
    }
  }

  void signUp() async {
    try {
      final client = sl<RestClient>();
      final userResp = await client.addUser(AddUser(
        user: NewUser(
          username: nameController.value.text,
          password: passwordController.value.text,
        ),
      ));
      sl<AuthManager>().login(userResp.user);
      Get.back(result: userResp.user);
    } catch (e) {
      SnackBarUtil.showError(e);
    }
  }

  @override
  void onClose() {
    super.onClose();
    passwordController.dispose();
    nameController.dispose();
  }
}
