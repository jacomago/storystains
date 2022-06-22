import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/extensions.dart';
import 'package:storystains/common/utils/snackbar.dart';
import 'package:storystains/common/widget/app_bar.dart';
import 'package:storystains/common/widget/widget.dart';

import '../features/auth/auth_state.dart';

class LoginOrRegisterPage extends StatelessWidget {
  LoginOrRegisterPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void afterLoging(BuildContext context, AuthState auth) {
    if (auth.isAuthenticated) {
      Navigator.of(context).pop();
      context.snackbar('Signed in as ${auth.user?.username}');
    } else {
      _passwordController.clear();
      context.snackbar('Sign in failed. Please try again.');
    }
  }

  void _onLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final username = _usernameController.text;
    final password = _passwordController.text;
    final empty = username.isEmpty || password.isEmpty;

    if (empty) {
      context.snackbar('Wrong username or password.');

      return;
    }

    await auth.loginRegister(username, password).then((value) {
      afterLoging(context, auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const StainsAppBar(
        title: AppBarTitle('Login/Register'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(60),
          child: Consumer<AuthState>(
            builder: (_, auth, __) =>
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: SvgPicture.asset(
                  'assets/logo/logo.svg',
                  height: 110,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  hintText: 'Enter your Username',
                ),
                controller: _usernameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter your secure password',
                ),
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onLogin(context),
              ),
              const SizedBox(height: 24),
              MaterialButton(
                onPressed: () => _onLogin(context),
                height: 50,
                minWidth: 150,
                color: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.isLogin ? 'Login' : 'Register',
                  style: context.labelLarge!
                      .copyWith(color: context.colors.onPrimary),
                ),
              ),
              TextButton(
                onPressed: auth.switchLoginRegister,
                child: Text(
                  auth.isLogin ? 'Register?' : 'Login?',
                  style: context.labelMedium,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
