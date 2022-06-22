import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/auth/auth_state.dart';
import 'package:storystains/routes/routes.dart';

class StainsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StainsAppBar({
    Key? key,
    required this.title,
    this.moreActions = const [],
  }) : super(key: key);
  final List<Widget> moreActions;
  final Widget? title;

  final Size appBarHeight = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      toolbarHeight: 70,
      backgroundColor: context.colors.surfaceVariant,
      actions: [
        ...moreActions,
        _buildAuthAction(context),
      ],
    );
  }

  Widget _buildAuthAction(BuildContext context) {
    var authState = Provider.of<AuthState>(context);

    return authState.isAuthenticated
        ? IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => context.push(Routes.account),
          )
        : IconButton(
            onPressed: () => context.push(Routes.login),
            icon: const Icon(Icons.login),
          );
  }

  @override
  Size get preferredSize => appBarHeight;
}
