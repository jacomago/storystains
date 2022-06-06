import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';

import '../../common/widget/app_bar.dart';
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Obx(() {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      48,
                      144,
                      48,
                      96,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo/logo.png',
                        height: 110,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'user name',
                          hintText: 'Enter your user name'),
                      controller: controller.nameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter your secure password'),
                      controller: controller.passwordController,
                    ),
                  ),
                  const SizedBox(height: 96),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: MaterialButton(
                      onPressed: () => controller.state.isLogin.value
                          ? controller.signIn()
                          : controller.signUp(),
                      height: 96,
                      minWidth: 600,
                      color: context.colors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48)),
                      child: Text(
                        controller.state.isLogin.value ? 'Sign in' : 'Sign up',
                        style: context.labelLarge,
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
                      style: context.labelMedium,
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
