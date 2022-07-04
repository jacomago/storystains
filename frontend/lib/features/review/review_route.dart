import 'package:flutter/material.dart';
import 'review.dart';

import 'review_model.dart';

class ReviewRoutePath {
  final String slug;
  final String username;

  ReviewRoutePath(this.slug, this.username);

  MaterialPageRoute<Review> route(
    String routeName,
    Review review,
    Widget Function(Review) builder,
  ) =>
      MaterialPageRoute<Review>(
        settings: RouteSettings(
          name: '$routeName/$username/$slug',
        ),
        builder: (context) => builder(review),
      );
}
