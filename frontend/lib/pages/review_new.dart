import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';

class ReviewNew extends StatelessWidget {
  const ReviewNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService()),
      child: const ReviewEditPage(),
    );
  }
}
