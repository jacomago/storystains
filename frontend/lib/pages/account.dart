import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../common/utils/utils.dart';
import '../common/widget/widget.dart';
import '../features/auth/auth_state.dart';

/// Display a users account Profile with personal actions
class AccountPage extends StatelessWidget {
  /// Display a users account Profile with personal actions
  const AccountPage({Key? key}) : super(key: key);

  void _afterDelete(BuildContext context, AuthState auth) {
    if (auth.isAuthenticated || auth.isFailed) {
      context.snackbar(context.locale.actionFailed(context.locale.deleteObject(
        context.locale.user,
      )));
    } else {
      Navigator.of(context).pop();
      context
          .snackbar(context.locale.actionSucceeded(context.locale.deleteObject(
        context.locale.user,
      )));
    }
  }

  void _onDelete(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();

    await auth.delete().then((value) {
      _afterDelete(context, auth);
    });
  }

  void _afterLogout(BuildContext context, AuthState auth) {
    if (auth.isAuthenticated || auth.isFailed) {
      context.snackbar(context.locale.actionFailed(context.locale.logout));
    } else {
      Navigator.of(context).pop();
      context.snackbar(context.locale.actionSucceeded(context.locale.logout));
    }
  }

  void _onLogout(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();

    await auth.logout().then((value) {
      _afterLogout(context, auth);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: StainsAppBar(
          title: AppBarTitle(
            context.locale.account,
          ),
        ),
        bottomNavigationBar: const NavBar(
          currentNav: NavOption.account,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(60),
            child: Consumer<AuthState>(
              builder: (_, auth, __) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/logo/logo_circle_plain.svg',
                      height: 110,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.locale.greeting(
                      auth.user?.username ?? context.locale.user,
                    ),
                    style: context.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                    ),
                    onPressed: () => _onLogout(context),
                    child: Text(
                      context.locale.logout,
                      style: context.labelLarge!
                          .copyWith(color: context.colors.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _onDelete(context),
                    child: Text(
                      context.locale.deleteObject(context.locale.user),
                      style: context.labelLarge!
                          .copyWith(color: context.colors.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
