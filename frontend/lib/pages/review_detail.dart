import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/review/review.dart';

class ReviewDetail extends StatelessWidget {
  const ReviewDetail({Key? key, this.path, this.review}) : super(key: key);

  final Review? review;
  final ReviewRoutePath? path;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService(), path: path, review: review),
      child: const ReviewWidget(),
    );
}
