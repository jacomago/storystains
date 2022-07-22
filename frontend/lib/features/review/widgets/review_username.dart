import 'package:flutter/material.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../../pages/user_profile.dart';
import '../../../routes/routes.dart';
import '../../user/user.dart';

/// Formatting of display of a username on a review
class ReviewUsername extends StatelessWidget {
  /// Formatting of display of a username on a review
  const ReviewUsername({Key? key, required this.user}) : super(key: key);

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

  /// User Profile to display
  final UserProfile user;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinkButton(
            onPressed: () => _tapItem(context),
            text: '@${user.username}',
            defaultStyle:
                context.bodySmall!.copyWith(fontStyle: FontStyle.italic),
            semanticsLabel: context.locale.username,
          ),
        ],
      );
}
