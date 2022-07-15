import 'package:flutter/material.dart';
import 'review.dart';

import 'review_model.dart';

/// Representation of the url path of a review
class ReviewRoutePath {
  /// slug of the review url
  final String slug;

  /// username of the url
  final String username;

  /// Representation of the url path of a review
  ReviewRoutePath(this.slug, this.username);
}

/// url route for a [Review]
extension PageRoute on Review {
  /// url route for a [Review]
  MaterialPageRoute<Review> route(
    String routeName,
    Widget Function(Review) builder,
  ) =>
      MaterialPageRoute<Review>(
        settings: RouteSettings(
          name: '$routeName/${user.username}/$slug',
        ),
        builder: (context) => builder(this),
      );
}
