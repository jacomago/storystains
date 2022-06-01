import 'package:flutter/material.dart';

import 'package:storystains/models/review.dart';

class ReviewItem extends StatelessWidget {
  final Review review;

  const ReviewItem(this.review, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 20,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        leading: ClipOval(
          child: Container(
            color: Colors.grey.withOpacity(0.25),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.person),
          ),
        ),
        title: Text(review.title),
        subtitle: Text(review.review),
      ),
    );
  }
}
