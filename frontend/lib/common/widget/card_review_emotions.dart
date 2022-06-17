import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/common/widget/emotion_picker.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/emotions/emotion_state.dart';
import 'package:storystains/features/review_emotions/review_emotions_state.dart';
import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';

class EmotionClipper extends CustomClipper<Rect> {
  @override
  getClip(Size size) {
    var path = Rect.fromCenter(
      center: size.center(Offset(-0.2 * size.width, 0)),
      width: size.width * 0.8,
      height: size.height,
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

class CardReviewEmotionsList extends StatelessWidget {
  const CardReviewEmotionsList({Key? key}) : super(key: key);

  void _updateEmotion(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
    Emotion? value,
  ) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionsState>();

    if (value == null) {
      context.snackbar('Must choose an emotion.');

      return;
    }

    await state.edit(index, value);
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 6,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: reviewEmotions.items
                      .mapIndexed((i, e) => _buildEmotionItem(context, e, i))
                      .toList(),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: TextButton(
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
                  style: context.headlineSmall,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
  ) {
    return EmotionEdit(
      emotion: reviewEmotion.emotion,
      width: 50,
      height: 60,
      handler: (value) => _updateEmotion(context, reviewEmotion, index, value),
    );
  }
}
