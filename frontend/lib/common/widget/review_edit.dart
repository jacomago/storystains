import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/review_emotion_list.dart';
import 'package:storystains/features/emotions/emotion.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/review_emotions/review_emotions.dart';

class ReviewEditPage extends StatelessWidget {
  const ReviewEditPage({Key? key}) : super(key: key);

  void afterSend(BuildContext context, ReviewState state) {
    if (state.isUpdated) {
      context.pop(state.review);
      final msg = state.isCreate ? 'Created Review' : 'Updated Review';
      context.snackbar(msg);
    } else {
      if (state.isFailed) {
        context.snackbar(state.error);
      } else {
        context.snackbar('Review creation failed, please try again.');
      }
    }
  }

  void editReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();
    final body = state.bodyController.value.text;
    final title = state.titleController.value.text;

    if (title.isEmpty) {
      context.snackbar('Title can\'t be blank');

      return;
    } else if (body.isEmpty) {
      context.snackbar('Content can\'t be blank');

      return;
    }

    if (state.isCreate) {
      await state
          .create(
            title,
            body,
          )
          .then((value) => afterSend(context, state));
    } else {
      await state
          .update(title, body)
          .then((value) => afterSend(context, state));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewState>(
      builder: (context, state, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Review'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Title',
                        hintText: 'Review title',
                      ),
                      style: context.headlineMedium,
                      controller: state.titleController,
                    ),
                  ),
                  MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (_) =>
                            ReviewEmotionsState(state.review!.emotions),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => EmotionsState(EmotionsService()),
                      ),
                    ],
                    child: const ReviewEmotionsList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Body',
                        alignLabelWithHint: true,
                        hintText: 'Write your review (in markdown)',
                      ),
                      style: context.bodySmall,
                      controller: state.bodyController,
                      minLines: 5,
                      maxLines: 50,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => editReview(context),
            backgroundColor: context.colors.primary,
            child: Icon(
              Icons.send_rounded,
              color: context.colors.onBackground,
            ),
          ),
        );
      },
    );
  }
}
