import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../review/review_state.dart';
import '../review_emotion.dart';

/// Widget for editing [ReviewEmotion] on a review
class ReviewEmotionEdit extends StatelessWidget {
  /// Widget for editing [ReviewEmotion] on a review
  const ReviewEmotionEdit({
    super.key,
    required this.cancelHandler,
    required this.okHandler,
    required this.deleteHandler,
    required this.state,
  });

  /// State of review emotion
  final ReviewEmotionState state;

  /// Hadler for cancel button
  final Function cancelHandler;

  /// Handler for OK button
  final void Function(ReviewEmotion) okHandler;

  /// Handler for delete button
  final Function deleteHandler;

  void _afterSend(BuildContext context, ReviewEmotionState state) {
    if (state.isUpdated) {
      final msg =
          state.isCreate ? 'Created ReviewEmotion' : 'Updated ReviewEmotion';
      context.snackbar(msg);
      okHandler(state.reviewEmotion!);
    } else if (state.isDeleted) {
      deleteHandler();
      const msg = 'Deleted ReviewEmotion';
      context.snackbar(msg);
    } else {
      if (state.isFailed) {
        cancelHandler();
        context.snackbar(state.error);
      } else {
        cancelHandler();
        context.snackbar('Review Emotion creation failed.');
      }
    }
  }

  void _cancelCreation(BuildContext context) async {
    cancelHandler();
  }

  void _editReviewEmotion(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final review = context.read<ReviewState>().review!;
    await state.update(review).then((value) => _afterSend(context, state));
  }

  void _deleteReviewEmotion(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final review = context.read<ReviewState>().review!;
    await state.delete(review).then((value) => _afterSend(context, state));
  }

  @override
  Widget build(BuildContext context) => Consumer<ReviewState>(
        builder: (context, review, _) => SizedBox(
          height: 190,
          child: Row(
            children: [
              EmotionEdit(
                emotion: state.emotionController.value,
                height: 100,
                handler: (value) => {state.emotionController.value = value!},
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PositionEdit(
                      positionController: state.positionController,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: MarkdownEdit(
                        title: context.locale.notes,
                        bodyController: state.notesController,
                        hint: context.locale.markdownNotes,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _buildButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _deleteButton(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: context.colors.errorContainer,
        ),
        onPressed: () {
          _deleteReviewEmotion(context);
        },
        child: Text(
          context.locale.delete,
          style: context.labelLarge!.copyWith(
            color: context.colors.onErrorContainer,
          ),
        ),
      );
  Widget _editButton(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: context.colors.secondary,
        ),
        onPressed: () {
          _editReviewEmotion(context);
        },
        child: Text(
          context.locale.ok,
          style: context.labelLarge!.copyWith(
            color: context.colors.onPrimary,
          ),
        ),
      );
  Widget _cancelButton(BuildContext context) => OutlinedButton(
        onPressed: () {
          _cancelCreation(context);
        },
        child: Text(
          context.locale.cancel,
          style: context.labelLarge,
        ),
      );
  Widget _buildButtons(BuildContext context) => SizedBox(
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _deleteButton(context),
            Row(
              children: [
                _editButton(context),
                _cancelButton(context),
              ],
            ),
          ],
        ),
      );
}
