import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../common/utils/utils.dart';
import '../../common/widget/widget.dart';
import '../review/review_state.dart';
import 'review_emotion.dart';

/// Widget for editing [ReviewEmotion] on a review
class ReviewEmotionEdit extends StatelessWidget {
  /// Widget for editing [ReviewEmotion] on a review
  const ReviewEmotionEdit({
    Key? key,
    required this.cancelHandler,
    required this.okHandler,
    required this.deleteHandler,
  }) : super(key: key);

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

    final state = context.read<ReviewEmotionState>();
    final review = context.read<ReviewState>().review!;
    await state.update(review).then((value) => _afterSend(context, state));
  }

  void _deleteReviewEmotion(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionState>();
    final review = context.read<ReviewState>().review!;
    await state.delete(review).then((value) => _afterSend(context, state));
  }

  @override
  Widget build(BuildContext context) =>
      Consumer2<ReviewEmotionState, ReviewState>(
        builder: (context, state, review, _) => SizedBox(
          height: 190,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: EmotionEdit(
                  emotion: state.emotionController.value,
                  height: 100,
                  width: 100,
                  handler: (value) => {state.emotionController.value = value!},
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PositionEdit(
                      positionController: state.positionController,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: MarkdownEdit(
                        title: AppLocalizations.of(context)!.notes,
                        bodyController: state.notesController,
                        hint: AppLocalizations.of(context)!.markdownNotes,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: context.colors.errorContainer,
                            ),
                            onPressed: () {
                              _deleteReviewEmotion(context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.delete,
                              style: context.button!.copyWith(
                                color: context.colors.onErrorContainer,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: context.colors.secondary,
                                ),
                                onPressed: () {
                                  _editReviewEmotion(context);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.ok,
                                  style: context.button!.copyWith(
                                    color: context.colors.onPrimary,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  _cancelCreation(context);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: context.button,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
