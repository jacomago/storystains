import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/common/widget/emotion_dialog.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/emotions/emotion_state.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/features/review_emotion/review_emotion_edit.dart';
import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';

import 'review_emotions_state.dart';

class ReviewEmotionsList extends StatelessWidget {
  const ReviewEmotionsList({Key? key}) : super(key: key);

  _updateEmotion(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    Emotion? value,
  ) {
    UnimplementedError("not done");
  }

  void _addEmotion(BuildContext context, Emotion? value) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionsState>();

    if (value == null) {
      context.snackbar('Must choose an emotion.');

      return;
    }

    await state.create(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewEmotionsState, EmotionsState>(
      builder: (_, reviewEmotions, emotions, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Emotions",
                        style: context.headlineMedium,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async => {
                          showDialog<Emotion>(
                            context: context,
                            builder: (context) {
                              return EmotionDialog(
                                initialEmotion: emotions.emotionDefault,
                              );
                            },
                          ).then(
                            (value) => _addEmotion(context, value),
                          ),
                        },
                        child: Text(
                          "Add",
                          style: context.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  reviewEmotions.newItem
                      ? ChangeNotifierProvider(
                          create: (_) => ReviewEmotionState(
                            ReviewEmotionService(),
                            emotion: reviewEmotions.newEmotion,
                          ),
                          child: const ReviewEmotionEdit(),
                        )
                      : Column(),
                ],
              ),
              Timeline(
                indicators: reviewEmotions.items
                    .map((e) => _buildEmotionItem(context, e))
                    .toList(),
                children: reviewEmotions.items
                    .map((e) => _buildReviewEmotionItem(context, e))
                    .toList(),
              ),
            ],
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
      onTap: () => {
        UnimplementedError("not done"),
      },
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
    ReviewEmotion reviewEmotion,
  ) {
    return EmotionEdit(
      emotion: reviewEmotion.emotion,
      handler: (value) => _updateEmotion(context, reviewEmotion, value),
    );
  }
}
