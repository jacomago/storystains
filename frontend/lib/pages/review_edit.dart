import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';

class ReviewEdit<Review> extends StatelessWidget {
  const ReviewEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReviewArguement;

    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService(), args.review),
      child: const ReviewEditPage(),
    );
  }
}
