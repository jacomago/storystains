import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';

class CardReviewEmotionsList extends StatelessWidget {
  const CardReviewEmotionsList({Key? key, required this.items})
      : super(key: key);
  final List<ReviewEmotion> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .mapIndexed((i, e) => _buildEmotionItem(context, e, i))
            .toList(),
      ),
    );
  }

  Widget _buildEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
  ) {
    return EmotionImageText(
      emotion: reviewEmotion.emotion,
      width: 60,
      height: 60,
    );
  }
}
