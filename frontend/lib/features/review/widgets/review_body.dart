import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/review/review.dart';

class ReviewBody extends StatelessWidget {
  const ReviewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewState>(builder: (context, state, _) {
      return state.isEdit
          ? MarkdownEdit(
              bodyController: state.bodyController,
              title: 'Body',
            )
          : Markdown(
              physics: const NeverScrollableScrollPhysics(),
              data: state.review?.body ?? '',
              selectable: true,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            );
    });
  }
}
