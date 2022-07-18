import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        AppLocalizations.of(context)!.greeting(auth.user?.username ?? ''),
      );
    } else {
      _passwordController.clear();
      context.snackbar(AppLocalizations.of(context)!
          .actionFailed(AppLocalizations.of(context)!.login));
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
        AppLocalizations.of(context)!.or(
          AppLocalizations.of(context)!
              .blankStringError(AppLocalizations.of(context)!.username),
          AppLocalizations.of(context)!
              .blankStringError(AppLocalizations.of(context)!.password),
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
            AppLocalizations.of(context)!.or(
              AppLocalizations.of(context)!.login,
              AppLocalizations.of(context)!.signUp,
            ),
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(60),
            child: Consumer<AuthState>(
              builder: (_, auth, __) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo/logo.png',
                      height: 110,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.username,
                      hintText: AppLocalizations.of(context)!.usernameHint,
                    ),
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.password,
                      hintText: AppLocalizations.of(context)!.passwordHint,
                    ),
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLogin(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: context.colors.secondary,
                      minimumSize: const Size(120, 40),
                      elevation: 0,
                    ),
                    onPressed: () => _onLogin(context),
                    child: Text(
                      auth.isLogin
                          ? AppLocalizations.of(context)!.login
                          : AppLocalizations.of(context)!.signUp,
                      style: context.button!
                          .copyWith(color: context.colors.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  OutlinedButton(
                    onPressed: auth.switchLoginRegister,
                    child: Text(
                      auth.isLogin
                          ? AppLocalizations.of(context)!
                              .choice(AppLocalizations.of(context)!.signUp)
                          : AppLocalizations.of(context)!
                              .choice(AppLocalizations.of(context)!.login),
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
