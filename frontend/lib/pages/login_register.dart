import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/utils/extensions.dart';
import 'package:storystains/utils/snackbar.dart';

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

    if (auth.isLogin) {
      await auth.login(username, password).then((value) {
        afterLoging(context, auth);
      });
    } else {
      await auth.register(username, password).then((value) {
        afterLoging(context, auth);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Login/Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Consumer<AuthState>(
              builder: (_, auth, __) => Column(
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
                          labelText: 'Username',
                          hintText: 'Enter your Username'),
                      controller: _usernameController,
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
                      controller: _passwordController,
                    ),
                  ),
                  const SizedBox(height: 96),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: MaterialButton(
                      onPressed: () => _onLogin(context),
                      height: 96,
                      minWidth: 600,
                      color: context.colors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48)),
                      child: Text(
                        auth.isLogin ? 'Sign in' : 'Sign up',
                        style: context.labelLarge,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      auth.switchLoginRegister();
                    },
                    child: Text(
                      auth.isLogin
                          ? 'New User? Create Account'
                          : 'Has Account? To Login',
                      style: context.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
