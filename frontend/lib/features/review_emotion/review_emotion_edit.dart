import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/markdown_edit.dart';
import 'package:storystains/features/review/review_state.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/model/entity/review_emotion.dart';

import '../../common/widget/widget.dart';

class ReviewEmotionEdit extends StatelessWidget {
  const ReviewEmotionEdit({Key? key}) : super(key: key);

  void afterSend(BuildContext context, ReviewEmotionState state) {
    if (state.isUpdated) {
      context.pop(state.reviewEmotion);
      final msg =
          state.isCreate ? 'Created ReviewEmotion' : 'Updated ReviewEmotion';
      context.snackbar(msg);
    } else {
      if (state.isFailed) {
        context.snackbar(state.error);
      } else {
        context.snackbar('ReviewEmotion creation failed, please try again.');
      }
    }
  }

  void editReviewEmotion(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewEmotionState>();
    final slug = context.read<ReviewState>().review!.slug;
    final notes = state.notesController.value.text;
    final position = state.positionController.value;
    final emotion = state.emotionController.value;

    if (state.isCreate) {
      await state
          .create(
            ReviewEmotion(
              position: position,
              emotion: emotion,
              notes: notes,
            ),
            slug,
          )
          .then((value) => afterSend(context, state));
    } else {
      await state
          .update(
            slug,
            state.reviewEmotion!.position,
            ReviewEmotion(
              position: position,
              emotion: emotion,
              notes: notes,
            ),
          )
          .then((value) => afterSend(context, state));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewEmotionState, ReviewState>(
      builder: (context, state, review, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              EmotionEdit(
                emotion: state.emotionController.value,
                handler: (value) => {state.emotionController.value = value!},
              ),
              PositionEdit(
                positionController: state.positionController,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: MarkdownEdit(
                  bodyController: state.notesController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
