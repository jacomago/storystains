
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';

import '../common/widget/review_edit.dart';

class CreateReview extends StatelessWidget {
  const CreateReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService()),
      child: ReviewEditPage(),
    );
  }
}