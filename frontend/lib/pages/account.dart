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
              MaterialButton(
                onPressed: () => _onDelete(context),
                height: 50,
                minWidth: 150,
                color: context.colors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Delete User',
                  style: context.labelLarge!
                      .copyWith(color: context.colors.onError),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
