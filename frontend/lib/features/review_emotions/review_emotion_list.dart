import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/utils/utils.dart';
import '../emotions/emotion.dart';
import '../review_emotion/review_emotion.dart';

import '../review_emotion/widgets/review_emotion.dart';
import 'review_emotions_state.dart';

/// List of r[ReviewEmotion] widget
class ReviewEmotionsList extends StatelessWidget {
  /// List of review emotions widget
  const ReviewEmotionsList({Key? key, required this.state}) : super(key: key);

  final ReviewEmotionsState state;

  void _updateEmotion(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
    Emotion? value,
  ) async {
    FocusScope.of(context).unfocus();

    if (value == null) {
      context.snackbar(context.locale.blankStringError(context.locale.emotion));

      return;
    }

    await state.edit(index, value);
  }

  void _addEmotion(BuildContext context, Emotion? value) async {
    FocusScope.of(context).unfocus();

    if (value == null) {
      context.snackbar(context.locale.blankStringError(context.locale.emotion));

      return;
    }

    await state.create(value);
  }

  @override
  Widget build(BuildContext context) => Consumer<EmotionsState>(
        builder: (_, emotions, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.locale.emotions,
                  style: context.titleMedium,
                ),
                OutlinedButton(
                  onPressed: () async => {
                    showDialog<Emotion>(
                      context: context,
                      builder: (context) => EmotionDialog(
                        initialEmotion: emotions.emotionDefault,
                      ),
                    ).then(
                      (value) => _addEmotion(context, value),
                    ),
                  },
                  child: Text(
                    context.locale.add,
                    style: context.button,
                  ),
                ),
              ],
            ),
            (state.newItem || state.editItem)
                ? ChangeNotifierProvider(
                    create: (_) => ReviewEmotionState(
                      ReviewEmotionService(),
                      emotion: state.currentEmotion,
                      reviewEmotion: state.currentReviewEmotion,
                    ),
                    child: ReviewEmotionEdit(
                      cancelHandler: state.cancelCreate,
                      okHandler: state.confirmCreation,
                      deleteHandler: state.confirmDelete,
                    ),
                  )
                : Row(),
            _itemList(state.items, context),
          ],
        ),
      );

  Widget _itemList(
    List<ReviewEmotion> reviewEmotions,
    BuildContext context,
  ) =>
      Column(
        children: reviewEmotions
            .mapIndexed<Widget>(
              (index, reviewEmotion) => Column(
                children: [
                  const SizedBox(height: 4),
                  ReviewEmotionWidget(
                    reviewEmotion: reviewEmotion,
                    emotionHandler: (value) =>
                        _updateEmotion(context, reviewEmotion, index, value),
                  ),
                ],
              ),
            )
            .toList(),
      );
}
