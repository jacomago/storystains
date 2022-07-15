import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../common/utils/utils.dart';
import '../common/widget/widget.dart';
import '../features/auth/auth.dart';
import '../features/reviews/reviews.dart';
import '../routes/routes.dart';

/// The home page of the app
class UserProfile extends StatelessWidget {
  /// The home page of the app
  const UserProfile({Key? key, required this.username}) : super(key: key);

  /// Username to filter review list by
  final String username;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewsState(
          ReviewsService(),
          ReviewQuery(username: username),
        ),
        child: const UserProfilePage(),
      );
}

/// The home page of the app
class UserProfilePage extends StatelessWidget {
  /// The home page of the app
  const UserProfilePage({Key? key}) : super(key: key);

  Future<void> _goNewReview(
    BuildContext context,
    ReviewsState reviewsState,
  ) async {
    context.push(Routes.reviewNew).then((value) => context.pop());
  }

  @override
  Widget build(BuildContext context) => Consumer2<ReviewsState, AuthState>(
        builder: (context, reviews, auth, _) => Scaffold(
          appBar: StainsAppBar(
            title: AppBarTitle(reviews.query!.username!),
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
