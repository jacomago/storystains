import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../common/utils/utils.dart';
import '../common/widget/widget.dart';
import '../features/auth/auth.dart';
import '../features/reviews/reviews.dart';
import '../routes/routes.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewsState(ReviewsService()),
        child: const HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _goNewReview(
    BuildContext context,
    ReviewsState reviewsState,
    AuthState authState,
  ) async {
    if (authState.isAuthenticated) {
      context.push(Routes.reviewNew).then((value) => reviewsState.refresh());
    } else {
      context.snackbar('Must be logged in to create a review.');
    }
  }

  static Widget buildAppTitle(BuildContext context) => SvgPicture.asset(
        'assets/images/titletext.svg',
        color: context.colors.onSurface,
        height: 35,
      );

  @override
  Widget build(BuildContext context) => Consumer2<ReviewsState, AuthState>(
        builder: (context, reviews, auth, _) => Scaffold(
          appBar: StainsAppBar(
            title: buildAppTitle(context),
          ),
          body: const ReviewList(),
          floatingActionButton: CustomFloatingButton(
            onPressed: () => _goNewReview(context, reviews, auth),
            icon: Icons.mode_edit_outline_sharp,
          ),
        ),
      );
}
