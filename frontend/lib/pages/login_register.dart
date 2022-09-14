import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../common/utils/extensions.dart';
import '../common/utils/snackbar.dart';
import '../common/widget/widget.dart';
import '../features/auth/auth.dart';

/// Page for logging in or registering user
class LoginOrRegisterPage extends StatelessWidget {
  /// Page for logging in or registering user
  LoginOrRegisterPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _afterLogin(BuildContext context, AuthState auth) {
    if (auth.isAuthenticated) {
      Navigator.of(context).pop();
      context.snackbar(
        context.locale.greeting(auth.user?.username ?? ''),
      );
    } else {
      _passwordController.clear();
      final message = context.locale.withError(
        context.locale.actionFailed(
          context.read<AuthState>().isLogin
              ? context.locale.login
              : context.locale.signUp,
        ),
        context.read<AuthState>().error,
      );
      context.snackbar(message);
    }
  }

  void _onLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final username = _usernameController.text;
    final password = _passwordController.text;
    final empty = username.isEmpty || password.isEmpty;

    if (empty) {
      context.snackbar(
        context.locale.or(
          context.locale.blankStringError(context.locale.username),
          context.locale.blankStringError(context.locale.password),
        ),
      );

      return;
    }

    await auth.loginRegister(username, password).then((value) {
      _afterLogin(context, auth);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: StainsAppBar(
          title: AppBarTitle(
            context.locale.or(
              context.locale.login,
              context.locale.signUp,
            ),
          ),
        ),
        bottomNavigationBar: const NavBar(
          currentNav: NavOption.account,
        ),
        body: Center(
          child: Consumer<AuthState>(
            builder: (_, auth, __) => SafeArea(
              child: ListView(
                restorationId: 'login_list_view',
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/logo/logo_circle_plain.svg',
                      height: 110,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.locale.username,
                      hintText: context.locale.usernameHint,
                    ),
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.locale.password,
                      hintText: context.locale.passwordHint,
                    ),
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLogin(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                      minimumSize: const Size(120, 40),
                      elevation: 0,
                    ),
                    onPressed: () => _onLogin(context),
                    child: Text(
                      auth.isLogin
                          ? context.locale.login
                          : context.locale.signUp,
                      style: context.button!
                          .copyWith(color: context.colors.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  OutlinedButton(
                    onPressed: auth.switchLoginRegister,
                    child: Text(
                      auth.isLogin
                          ? context.locale.choice(context.locale.signUp)
                          : context.locale.choice(context.locale.login),
                      style: context.button,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
