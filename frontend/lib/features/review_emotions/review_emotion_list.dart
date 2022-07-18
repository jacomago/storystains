import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../common/utils/utils.dart';
import '../../common/widget/widget.dart';
import '../emotions/emotion.dart';
import '../review_emotion/review_emotion.dart';

import 'review_emotions_state.dart';

/// List of r[ReviewEmotion] widget
class ReviewEmotionsList extends StatelessWidget {
  /// List of review emotions widget
  const ReviewEmotionsList({Key? key}) : super(key: key);

  void _updateEmotion(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
    Emotion? value,
  ) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionsState>();

    if (value == null) {
      context.snackbar(AppLocalizations.of(context)!
          .blankStringError(AppLocalizations.of(context)!.emotion));

      return;
    }

    await state.edit(index, value);
  }

  void _addEmotion(BuildContext context, Emotion? value) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionsState>();

    if (value == null) {
      context.snackbar(AppLocalizations.of(context)!
          .blankStringError(AppLocalizations.of(context)!.emotion));

      return;
    }

    await state.create(value);
  }

  @override
  Widget build(BuildContext context) =>
      Consumer2<ReviewEmotionsState, EmotionsState>(
        builder: (_, reviewEmotions, emotions, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.emotions,
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
                    AppLocalizations.of(context)!.add,
                    style: context.button,
                  ),
                ),
              ],
            ),
            (reviewEmotions.newItem || reviewEmotions.editItem)
                ? ChangeNotifierProvider(
                    create: (_) => ReviewEmotionState(
                      ReviewEmotionService(),
                      emotion: reviewEmotions.currentEmotion,
                      reviewEmotion: reviewEmotions.currentReviewEmotion,
                    ),
                    child: ReviewEmotionEdit(
                      cancelHandler: reviewEmotions.cancelCreate,
                      okHandler: reviewEmotions.confirmCreation,
                      deleteHandler: reviewEmotions.confirmDelete,
                    ),
                  )
                : Row(),
            Timeline(
              gutterSpacing: 10,
              indicatorSize: 110,
              indicators: reviewEmotions.items
                  .mapIndexed((i, e) => _buildEmotionItem(context, e, i))
                  .toList(),
              children: reviewEmotions.items
                  .map((e) => _buildReviewEmotionItem(context, e))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _buildReviewEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
  ) =>
      GestureDetector(
        onTap: () => {
          UnimplementedError('not done'),
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.notes,
                    style: context.labelLarge,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .positionPercentage(reviewEmotion.position),
                    style: context.labelMedium,
                  ),
                ],
              ),
              const Divider(),
              Text(
                reviewEmotion.notes,
                textAlign: TextAlign.left,
                style: context.bodySmall,
              ),
            ],
          ),
        ),
      );

  Widget _buildEmotionItem(
    BuildContext context,
    ReviewEmotion reviewEmotion,
    int index,
  ) =>
      EmotionEdit(
        emotion: reviewEmotion.emotion,
        height: 100,
        handler: (value) =>
            _updateEmotion(context, reviewEmotion, index, value),
      );
}
