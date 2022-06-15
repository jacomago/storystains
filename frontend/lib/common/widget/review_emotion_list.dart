import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'package:storystains/common/widget/emotion_dialog.dart';
import 'package:storystains/common/widget/timeline.dart';
import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';

import '../../features/review_emotions/review_emotions_state.dart';

class ReviewEmotionsList extends StatelessWidget {
  const ReviewEmotionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewEmotionsState>(
      builder: (_, reviewEmotions, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Timeline(
            indicators: reviewEmotions.items
                .map((e) => _buildEmotionItem(context, e.emotion))
                .toList(),
            children: reviewEmotions.items
                .map((e) => _buildReviewEmotionItem(context, e))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildReviewEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
  ) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Text("Position: $reviewEmotion.position"),
          Text(reviewEmotion.notes),
        ]),
      ),
    );
  }

  Widget _buildEmotionItem(
    BuildContext context,
    Emotion emotion,
  ) {
    return GestureDetector(
      onTap: () => showDialog<Emotion>(
        context: context,
        builder: (context) {
          return EmotionDialog(initialEmotion: emotion);
        },
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          SvgPicture.network(emotion.icon_url),
          Text(emotion.name),
        ]),
      ),
    );
  }
}
