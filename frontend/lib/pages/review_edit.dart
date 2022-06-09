import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';
import '../common/widget/review_edit.dart';

class EditReview extends StatelessWidget {
  const EditReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReviewArguement;

    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService(), args.review),
      child: ReviewEditPage(),
    );
  }
}
