import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/review/review.dart';

class ReviewTitle extends StatelessWidget {
  const ReviewTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewState>(builder: (context, state, _) {
      return state.isEdit
          ? TextField(
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
                hintText: 'Review title',
              ),
              style: context.titleMedium,
              controller: state.titleController,
            )
          : Text(
              state.review?.story.title ?? (state.isFailed ? 'Not Found' : ''),
              style: context.headlineSmall,
              semanticsLabel: 'Title',
            );
    });
  }
}
