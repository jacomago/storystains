import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/emotion_image_text.dart';
import 'package:storystains/features/emotions/emotion_state.dart';
import 'package:storystains/features/review_emotions/review_emotions_state.dart';
import 'package:storystains/model/entity/review_emotion.dart';

class CardReviewEmotionsList extends StatelessWidget {
  const CardReviewEmotionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewEmotionsState, EmotionsState>(
      builder: (_, reviewEmotions, emotions, __) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: reviewEmotions.items
                .mapIndexed((i, e) => _buildEmotionItem(context, e, i))
                .toList(),
          ),
        );
      },
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
