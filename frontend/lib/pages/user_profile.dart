import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/reviews/reviews.dart';
import '../features/user/user.dart';

/// The home page of the app
class UserProfilePage extends StatelessWidget {
  /// The home page of the app
  const UserProfilePage({super.key, required this.user});

  /// Username to filter review list by
  final UserProfile user;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewsState(
          ReviewsService(),
          ReviewQuery(username: user.username),
        ),
        child: UserWidget(
          user: user,
        ),
      );
}
