import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';

class ReviewEdit<T> extends StatelessWidget {
  const ReviewEdit({
    Key? key,
    this.path,
    this.review,
  }) : super(key: key);

  final Review? review;
  final ReviewRoutePath? path;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewState(
        ReviewService(),
        review: review,
      ),
      child: const ReviewEditPage(),
    );
  }
}
