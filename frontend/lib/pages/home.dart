import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/app_bar.dart';
import 'package:storystains/common/widget/custom_floating_button.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/reviews/reviews.dart';
import 'package:storystains/routes/routes.dart';
import 'package:storystains/common/utils/extensions.dart';
import 'package:storystains/common/utils/navigation.dart';
import 'package:storystains/common/utils/snackbar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsState(ReviewsService()),
      child: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  _goNewReview(
    BuildContext context,
    ReviewsState reviewsState,
    AuthState authState,
  ) async {
    if (authState.isAuthenticated) {
      context.push(Routes.reviewNew).then((value) => reviewsState.refresh());
    } else {
      context.snackbar("Must be logged in to create a review.");
    }
  }

  static Widget buildAppTitle(BuildContext context) {
    return SvgPicture.asset(
      "assets/images/titletext.svg",
      color: context.colors.onSurface,
      height: 35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewsState, AuthState>(
      builder: (context, reviews, auth, _) {
        return Scaffold(
          appBar: StainsAppBar(
            title: buildAppTitle(context),
          ),
          body: const ReviewList(),
          floatingActionButton: CustomFloatingButton(
            onPressed: () => _goNewReview(context, reviews, auth),
            icon: Icons.mode_edit_outline_sharp,
          ),
        );
      },
    );
  }
}
