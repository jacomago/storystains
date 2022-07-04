import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/review/review.dart';

class ReviewNew extends StatelessWidget {
  const ReviewNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ReviewState(ReviewService()),
        child: const ReviewWidget(),
      );
}
