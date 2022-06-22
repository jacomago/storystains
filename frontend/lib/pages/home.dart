import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/widget/app_bar.dart';
import 'package:storystains/features/reviews/reviews_service.dart';
import 'package:storystains/routes/routes.dart';
import 'package:storystains/common/utils/extensions.dart';
import 'package:storystains/common/utils/navigation.dart';
import 'package:storystains/common/utils/snackbar.dart';

import '../features/reviews/review_list.dart';
import '../features/auth/auth_state.dart';
import '../features/reviews/reviews_state.dart';

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

  Widget _buildTitle(BuildContext context) {
    return Text(
      AppConfig.appName,
      style: context.displayMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewsState, AuthState>(
      builder: (context, reviews, auth, _) {
        return Scaffold(
          appBar: StainsAppBar(
            title: _buildTitle(context),
          ),
          body: const ReviewsPage(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _goNewReview(context, reviews, auth),
            backgroundColor: context.colors.primary,
            child: Icon(
              Icons.add_rounded,
              size: 56,
              color: context.colors.onPrimary,
            ),
          ),
        );
      },
    );
  }
}
