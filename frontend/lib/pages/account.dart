import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      context.snackbar(AppLocalizations.of(context)!
          .actionFailed(AppLocalizations.of(context)!.deleteObject(
        AppLocalizations.of(context)!.user,
      )));
    } else {
      Navigator.of(context).pop();
      context.snackbar(AppLocalizations.of(context)!
          .actionSucceded(AppLocalizations.of(context)!.deleteObject(
        AppLocalizations.of(context)!.user,
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
      context.snackbar(AppLocalizations.of(context)!
          .actionFailed(AppLocalizations.of(context)!.logout));
    } else {
      Navigator.of(context).pop();
      context.snackbar(AppLocalizations.of(context)!
          .actionSucceded(AppLocalizations.of(context)!.logout));
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
            AppLocalizations.of(context)!.acount,
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
                    child: SvgPicture.asset(
                      'assets/logo/logo.svg',
                      height: 110,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.greeting(
                      auth.user?.username ?? AppLocalizations.of(context)!.user,
                    ),
                    style: context.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: context.colors.secondary,
                    ),
                    onPressed: () => _onLogout(context),
                    child: Text(
                      AppLocalizations.of(context)!.logout,
                      style: context.button!
                          .copyWith(color: context.colors.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _onDelete(context),
                    child: Text(
                      AppLocalizations.of(context)!
                          .deleteObject(AppLocalizations.of(context)!.user),
                      style: context.button!
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
