import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/utils/utils.dart';
import '../../common/widget/widget.dart';
import '../../routes/routes.dart';
import '../auth/auth.dart';
import '../reviews/reviews.dart';
import 'user.dart';

/// The page of a user
class UserWidget extends StatelessWidget {
  /// The page of a user
  const UserWidget({super.key, required this.user});

  /// User whose profile it is
  final UserProfile user;

  Future<void> _goNewReview(
    BuildContext context,
    ReviewsState reviewsState,
  ) async {
    context.pushNamed(Routes.reviewNew).then((value) => context.pop());
  }

  @override
  Widget build(BuildContext context) => Consumer2<ReviewsState, AuthState>(
        builder: (context, reviews, auth, _) => Scaffold(
          appBar: StainsAppBar(
            title: AppBarTitle(user.username),
          ),
          bottomNavigationBar: const NavBar(
            currentNav: NavOption.profile,
          ),
          body: const ReviewList(),
          floatingActionButton: auth.isAuthenticated
              ? CustomFloatingButton(
                  onPressed: () => _goNewReview(context, reviews),
                  icon: Icons.mode_edit_outline_sharp,
                )
              : null,
        ),
      );
}
