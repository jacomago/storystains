import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/modules/reviews/reviews.dart';

class Reviews extends StatelessWidget {
  const Reviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsState(ReviewsService()),
      child: const ReviewsPage(),
    );
  }
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReviewsState>(
        builder: (_, reviews, __) {
          return Container();
        },
      ),
    );
  }
}