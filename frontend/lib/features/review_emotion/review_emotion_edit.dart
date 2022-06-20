import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/markdown_edit.dart';
import 'package:storystains/features/review/review_state.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/model/entity/review_emotion.dart';

import '../../common/widget/widget.dart';

class ReviewEmotionEdit extends StatelessWidget {
  const ReviewEmotionEdit({
    Key? key,
    required this.cancelHandler,
    required this.okHandler,
  }) : super(key: key);

  final Function cancelHandler;
  final Function(ReviewEmotion) okHandler;

  void afterSend(BuildContext context, ReviewEmotionState state) {
    if (state.isUpdated) {
      final msg =
          state.isCreate ? 'Created ReviewEmotion' : 'Updated ReviewEmotion';
      context.snackbar(msg);
      okHandler(state.reviewEmotion!);
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
    final slug = context.read<ReviewState>().review!.slug;
    await state.update(slug).then((value) => afterSend(context, state));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewEmotionState, ReviewState>(
      builder: (context, state, review, _) {
        return SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 190,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: EmotionEdit(
                        emotion: state.emotionController.value,
                        height: 180,
                        handler: (value) =>
                            {state.emotionController.value = value!},
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
                            width: 10,
                          ),
                          Expanded(
                            child: MarkdownEdit(
                              bodyController: state.notesController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        editReviewEmotion(context);
                      },
                      child: Text(
                        "OK",
                        style: context.labelMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cancelCreation(context);
                      },
                      child: Text(
                        "Cancel",
                        style: context.labelMedium,
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
