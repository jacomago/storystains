import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/extensions.dart';
import 'package:storystains/common/utils/snackbar.dart';
import 'package:storystains/common/widget/app_bar.dart';
import 'package:storystains/common/widget/title.dart';

import '../features/auth/auth_state.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  void afterDelete(BuildContext context, AuthState auth) {
    if (auth.isAuthenticated || auth.isFailed) {
      context.snackbar('Delete user failed');
    } else {
      Navigator.of(context).pop();
      context.snackbar('Delete user succeded');
    }
  }

  void _onDelete(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();

    await auth.delete().then((value) {
      afterDelete(context, auth);
    });
  }

  void afterLogout(BuildContext context, AuthState auth) {
    if (auth.isAuthenticated || auth.isFailed) {
      context.snackbar('Logout user failed');
    } else {
      Navigator.of(context).pop();
      context.snackbar('Logout succeded');
    }
  }

  void _onLogout(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();

    await auth.logout().then((value) {
      afterLogout(context, auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const StainsAppBar(
        title: AppBarTitle(
          'User Account',
        ),
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
              Text(
                'Hello ${auth.user?.username}',
                style: context.bodyMedium,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(primary: context.colors.secondary),
                onPressed: () => _onLogout(context),
                child: Text(
                  'Log out',
                  style:
                      context.button!.copyWith(color: context.colors.onPrimary),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _onDelete(context),
                child: Text(
                  'Delete User',
                  style: context.button!
                      .copyWith(color: context.colors.onErrorContainer),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
