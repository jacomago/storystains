import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../features/review_emotion/review_emotion.dart';
import 'widget.dart';

/// List of Card like presented snippets of a [ReviewEmotion]
class CardReviewEmotionsList extends StatelessWidget {
  /// List of Card like presented snippets of a [ReviewEmotion]
  const CardReviewEmotionsList({Key? key, required this.items})
      : super(key: key);

  /// List of [ReviewEmotion]s to present
  final List<ReviewEmotion> items;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .mapIndexed((i, e) => _buildEmotionItem(context, e, i))
              .toList(),
        ),
      );

  Widget _buildEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
  ) =>
      EmotionImageText(
        emotion: reviewEmotion.emotion,
        height: 60,
        direction: AxisDirection.up,
      );
}
