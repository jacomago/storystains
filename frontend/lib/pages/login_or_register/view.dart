import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';

import '../../common/constant/app_config.dart';
import '../../common/constant/app_keys.dart';
import '../../common/constant/app_size.dart';
import '../../common/util/storage.dart';
import '../../common/widget/app_bar.dart';
import '../../common/widget/ripple_button.dart';
import 'logic.dart';

class LoginOrRegisterPage extends GetView<LoginOrRegisterLogic> {
  const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PageBar(
        context: context,
        title: 'Login/Register',
        rightMenu: GestureDetector(
          onTap: () => Get.dialog(SimpleDialog(
            title: const Text('Set the base url'),
            contentPadding: EdgeInsets.all(AppSize.w_24),
            children: [
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Base Url',
                  hintText:
                      Storage.getString(AppKeys.baseUrl) ?? AppConfig.baseUrl,
                ),
                controller: controller.urlController,
              ),
              SizedBox(height: AppSize.w_24),
              RippleButton(
                onTap: () => controller.setNewBaseUrl(),
                height: AppSize.w_96,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(AppSize.r_8)),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: AppSize.s_28,
                  ),
                ),
              )
            ],
          )),
          child: Icon(
            Icons.settings_rounded,
            size: AppSize.w_48,
            color: context.colors.primary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSize.w_16),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Obx(() {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSize.w_48,
                      AppSize.w_144,
                      AppSize.w_48,
                      AppSize.w_96,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.w_200),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo/logo.png',
                        height: AppSize.w_110,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSize.w_24),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'user name',
                          hintText: 'Enter your user name'),
                      controller: controller.nameController,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSize.w_24),
                    child: TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter your secure password'),
                      controller: controller.passwordController,
                    ),
                  ),
                  SizedBox(height: AppSize.w_96),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w_32),
                    child: MaterialButton(
                      onPressed: () => controller.state.isLogin.value
                          ? controller.signIn()
                          : controller.signUp(),
                      height: AppSize.w_96,
                      minWidth: AppSize.w_600,
                      color: context.colors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSize.w_48)),
                      child: Text(
                        controller.state.isLogin.value ? 'Sign in' : 'Sign up',
                        style: TextStyle(
                          color: context.colors.onBackground,
                          fontSize: AppSize.s_28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      controller.state.isLogin(!controller.state.isLogin.value);
                    },
                    child: Text(
                      controller.state.isLogin.value
                          ? 'New User? Create Account'
                          : 'Has Account? To Login',
                      style: TextStyle(
                          color: context.colors.onBackground,
                          fontSize: AppSize.s_24),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
