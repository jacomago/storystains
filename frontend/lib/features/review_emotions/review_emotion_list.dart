import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/utils/utils.dart';
import '../auth/auth.dart';
import '../emotions/emotion.dart';
import '../review/review.dart';
import '../review_emotion/review_emotion.dart';

import '../review_emotion/widgets/review_emotion.dart';
import 'review_emotions_state.dart';

/// List of r[ReviewEmotion] widget
class ReviewEmotionsList extends StatelessWidget {
  /// List of review emotions widget
  const ReviewEmotionsList({Key? key, required this.state}) : super(key: key);

  /// State of the list of emotions
  final ReviewEmotionsState state;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: ((context) => state),
        child: const ReviewEmotionsListWidget(),
      );
}

/// List of r[ReviewEmotion] widget
class ReviewEmotionsListWidget extends StatelessWidget {
  /// List of review emotions widget
  const ReviewEmotionsListWidget({Key? key}) : super(key: key);

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

    await context.read<ReviewEmotionsState>().edit(index, value);
  }

  void _addEmotion(BuildContext context, Emotion? value) async {
    FocusScope.of(context).unfocus();

    if (value == null) {
      context.snackbar(context.locale.blankStringError(context.locale.emotion));

      return;
    }

    await context.read<ReviewEmotionsState>().create(value);
  }

  bool _allowAdd(BuildContext context) {
    final reviewState = context.read<ReviewState>();

    return reviewState.review == null
        ? false
        : context.read<AuthState>().sameUser(reviewState.review!.user);
  }

  @override
  Widget build(BuildContext context) =>
      Consumer2<ReviewEmotionsState, EmotionsState>(
        builder: (_, state, emotions, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.locale.emotions,
                  style: context.titleMedium,
                ),
                _allowAdd(context)
                    ? OutlinedButton(
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
                      )
                    : Column(),
              ],
            ),
            ValueListenableBuilder<ReviewEmotionsEvent>(
              builder: (context, value, child) =>
                  value != ReviewEmotionsEvent.none
                      ? ReviewEmotionEdit(
                          cancelHandler: state.cancelCreate,
                          okHandler: state.confirmCreation,
                          deleteHandler: state.confirmDelete,
                          state: ReviewEmotionState(
                            ReviewEmotionService(),
                            emotion: state.currentEmotion,
                            reviewEmotion: state.currentReviewEmotion,
                          ),
                        )
                      : Row(),
              valueListenable: state.editing,
            ),
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
