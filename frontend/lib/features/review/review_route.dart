import 'package:flutter/material.dart';

import 'review_model.dart';

class ReviewRoute {
  static MaterialPageRoute<Review> route(
    String routeName,
    Review review,
    Widget Function(Review) builder,
  ) {
    return MaterialPageRoute<Review>(
      settings: RouteSettings(
        name: '$routeName/${review.user.username}/${review.slug}',
      ),
      builder: (BuildContext context) {
        return builder(review);
      },
    );
  }
}

class ReviewRoutePath {
  final String slug;
  final String username;

  ReviewRoutePath(this.slug, this.username);
}
