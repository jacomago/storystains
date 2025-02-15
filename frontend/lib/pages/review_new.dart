import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/review/review.dart';

/// Wrapper around [ReviewWidget] for creating new reviews
class ReviewNew extends StatelessWidget {
  /// Wrapper around [ReviewWidget] for creating new reviews
  const ReviewNew({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewState(ReviewService()),
        child: const ReviewWidget(),
      );
}
