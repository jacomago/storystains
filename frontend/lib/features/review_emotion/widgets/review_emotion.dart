import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../emotions/emotion.dart';
import '../review_emotion.dart';

/// Widget for editing [ReviewEmotion] on a review
class ReviewEmotionWidget extends StatelessWidget {
  /// Widget for editing [ReviewEmotion] on a review
  const ReviewEmotionWidget({
    Key? key,
    required this.reviewEmotion,
    required this.emotionHandler,
  }) : super(key: key);

  /// Handler after choosing an emotion
  final void Function(Emotion?) emotionHandler;

  /// Review Emotion to display
  final ReviewEmotion reviewEmotion;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EmotionEdit(
                emotion: reviewEmotion.emotion,
                height: 100,
                handler: emotionHandler,
              ),
              _buildPosition(context, reviewEmotion.position),
            ],
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: _buildReviewEmotionItem(context, reviewEmotion),
            ),
          ),
        ],
      );

  Widget _buildPosition(
    BuildContext context,
    int position,
  ) =>
      Text(
        context.locale.positionPercentage(position),
        style: context.labelMedium,
      );

  Widget _buildReviewEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.locale.notes,
                style: context.labelLarge,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const Divider(
            height: 4,
          ),
          MarkdownBody(
            data: reviewEmotion.notes ?? '',
          ),
        ],
      );
}
