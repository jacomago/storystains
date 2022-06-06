import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../common/constant/app_config.dart';
import '../../common/constant/app_keys.dart';
import '../../common/http/dio_manager.dart';
import '../../common/util/auth_manager.dart';
import '../../common/util/storage.dart';
import '../../common/util/snackbar.dart';
import '../../model/req/add_user.dart';
import '../../model/req/login.dart';
import '../../services/rest_client.dart';
import 'state.dart';

class LoginOrRegisterLogic extends GetxController {
  final LoginOrRegisterState state = LoginOrRegisterState();

  final passwordController = TextEditingController();

  final nameController = TextEditingController();

  final urlController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    urlController.text =
        Storage.getString(AppKeys.baseUrl) ?? AppConfig.baseUrl;
  }

  void signIn() async {
    try {
      final userResp = await RestClient.client.loginUser(Login(
        user: LoginUser(
          username: nameController.value.text,
          password: passwordController.value.text,
        ),
      ));
      AuthManager.login(userResp.user);
      Get.back(result: userResp.user);
    } catch (e) {
      SnackBarUtil.showError(e);
    }
  }

  void signUp() async {
    try {
      final userResp = await RestClient.client.addUser(AddUser(
        user: NewUser(
          username: nameController.value.text,
          password: passwordController.value.text,
        ),
      ));
      AuthManager.login(userResp.user);
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
    urlController.dispose();
  }
}
