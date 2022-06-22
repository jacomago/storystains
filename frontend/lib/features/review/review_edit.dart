import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/app_bar.dart';
import 'package:storystains/common/widget/markdown_edit.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/review_emotions/review_emotion_list.dart';
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
    } else if (state.isDeleted) {
      context.pop();
      const msg = "Deleted Review";
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

    await state.update(title, body).then((value) => afterSend(context, state));
  }

  void deleteReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();

    await state.delete().then((value) => afterSend(context, state));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewState>(
      builder: (context, state, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: StainsAppBar(
            title: const AppBarTitle('Review'),
            moreActions: [
              PopupMenuButton<Text>(
                icon: Icon(Icons.adaptive.more),
                itemBuilder: (BuildContext context) => <PopupMenuItem<Text>>[
                  PopupMenuItem(
                    child: Text(
                      "Delete",
                      style: context.labelSmall!
                          .copyWith(color: context.colors.error),
                    ),
                    onTap: () {
                      deleteReview(context);
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                      hintText: 'Review title',
                    ),
                    style: context.titleMedium,
                    controller: state.titleController,
                  ),
                  state.isCreate
                      ? Row()
                      : ChangeNotifierProvider(
                          create: (_) =>
                              ReviewEmotionsState(state.review!.emotions),
                          child: const ReviewEmotionsList(),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: MarkdownEdit(
                      bodyController: state.bodyController,
                      title: 'Body',
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
