import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../../pages/user_profile.dart';
import '../../../routes/routes.dart';
import '../../auth/auth.dart';
import '../../user/user.dart';

/// Formatting of display of a username on a review
class ReviewUsername extends StatelessWidget {
  /// Formatting of display of a username on a review
  const ReviewUsername({super.key, required this.user});

  void _tapItem(BuildContext context) {
    Navigator.of(context).push(
      user.route(
        Routes.userProfile,
        (u) => UserProfilePage(
          user: u,
        ),
      ),
    );
  }

  /// Swaps color to primary instead of null if authenticated user is the user
  /// being displayed
  static Color? changeColour(BuildContext context, UserProfile user) {
    var authUsername = context.read<AuthState>().user?.username;
    if (authUsername == null) {
      return null;
    }

    return authUsername == user.username ? context.colors.secondary : null;
  }

  /// User Profile to display
  final UserProfile user;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinkButton(
            onPressed: () => _tapItem(context),
            text: '@${user.username}',
            defaultStyle: context.bodySmall!.copyWith(
              fontStyle: FontStyle.italic,
              color: changeColour(context, user),
            ),
            semanticsLabel: context.locale.username,
          ),
        ],
      );
}
