import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth_state.dart';
import '../../routes/routes.dart';
import '../constant/app_theme.dart';
import '../utils/utils.dart';

/// Custom App bar for the Application
class StainsAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Custom App bar for the Application
  const StainsAppBar({
    Key? key,
    required this.title,
    this.moreActions = const [],
  }) : super(key: key);
  /// Extra actions beyond the defaults
  final List<Widget> moreActions;
  /// Title to show on the top
  final Widget? title;

  /// Height of the app bar, default 56.0
  final Size appBarHeight = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) => AppBar(
        title: title,
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: ExtraColors.paper,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: Divider(
            color: context.colors.secondary,
            height: 1.0,
          ),
        ),
        actions: [
          ...moreActions,
          _buildAuthAction(context),
        ],
        iconTheme: IconThemeData(color: context.colors.surface),
      );

  Widget _buildAuthAction(BuildContext context) {
    var authState = Provider.of<AuthState>(context);

    return authState.isAuthenticated
        ? IconButton(
            icon: const Icon(Icons.person_pin_sharp),
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
