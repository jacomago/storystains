import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/routes/routes.dart';
import 'package:storystains/utils/extensions.dart';
import 'package:storystains/utils/navigation.dart';
import 'package:storystains/utils/snackbar.dart';

import '../common/widget/review_list.dart';
import '../features/auth/auth_state.dart';
import '../features/reviews/reviews_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewsState, AuthState>(
      builder: (context, reviews, auth, _) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppConfig.appName), actions: [
            if (auth.isAuthenticated)
              IconButton(
                icon: const Icon(Icons.person_rounded),
                onPressed: () => context.snackbar(
                  'Hello ${auth.user?.username}',
                ),
              )
            else
              IconButton(
                  onPressed: () => context.push(Routes.login),
                  icon: const Icon(Icons.login)),
          ]),
          body: const ReviewsPage(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(Routes.reviewNew),
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
