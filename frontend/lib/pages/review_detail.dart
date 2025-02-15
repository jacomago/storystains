import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/review/review.dart';

/// Wrapper around [ReviewWidget] for showing a [Review]
class ReviewDetail extends StatelessWidget {
  /// Wrapper around [ReviewWidget] for showing a [Review]
  const ReviewDetail({super.key, this.path, this.review});

  /// Review to show in widget
  final Review? review;

  /// Path of the review
  final ReviewRoutePath? path;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewState(ReviewService(), path: path, review: review),
        child: const ReviewWidget(),
      );
}
