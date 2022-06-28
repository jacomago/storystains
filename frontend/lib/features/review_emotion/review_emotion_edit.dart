import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/review/review_state.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/common/utils/utils.dart';

class ReviewEmotionEdit extends StatelessWidget {
  const ReviewEmotionEdit({
    Key? key,
    required this.cancelHandler,
    required this.okHandler,
    required this.deleteHandler,
  }) : super(key: key);

  final Function cancelHandler;
  final Function(ReviewEmotion) okHandler;
  final Function deleteHandler;

  void afterSend(BuildContext context, ReviewEmotionState state) {
    if (state.isUpdated) {
      final msg =
          state.isCreate ? 'Created ReviewEmotion' : 'Updated ReviewEmotion';
      context.snackbar(msg);
      okHandler(state.reviewEmotion!);
    } else if (state.isDeleted) {
      deleteHandler();
      const msg = "Deleted ReviewEmotion";
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

  void cancelCreation(BuildContext context) async {
    cancelHandler();
  }

  void editReviewEmotion(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionState>();
    final review = context.read<ReviewState>().review!;
    await state.update(review).then((value) => afterSend(context, state));
  }

  void deleteReviewEmotion(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionState>();
    final review = context.read<ReviewState>().review!;
    await state.delete(review).then((value) => afterSend(context, state));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewEmotionState, ReviewState>(
      builder: (context, state, review, _) {
        return SizedBox(
          height: 190,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
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
                        bodyController: state.notesController,
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
                              deleteReviewEmotion(context);
                            },
                            child: Text(
                              "Delete",
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
                                  editReviewEmotion(context);
                                },
                                child: Text(
                                  "OK",
                                  style: context.button!.copyWith(
                                    color: context.colors.onPrimary,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  cancelCreation(context);
                                },
                                child: Text(
                                  "Cancel",
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
        );
      },
    );
  }
}
