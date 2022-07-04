import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../auth/auth.dart';
import '../../review_emotions/review_emotions.dart';
import '../../story/story.dart';
import '../review.dart';
import 'review_body.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({Key? key}) : super(key: key);

  void afterSend(BuildContext context, ReviewState state) {
    if (state.isUpdated) {
      context.pop(state.review);
      context.snackbar(AppLocalizations.of(context)!
          .updatedObject(AppLocalizations.of(context)!.review));
    } else if (state.isDeleted) {
      context.pop();
      context.snackbar(AppLocalizations.of(context)!
          .deletedObject(AppLocalizations.of(context)!.review));
    } else {
      if (state.isFailed) {
        context.snackbar(state.error);
      } else {
        context.snackbar(AppLocalizations.of(context)!.pleaseTryAgain);
      }
    }
  }

  void editReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();
    final body = state.bodyController.value.text;
    final story = state.storyContoller.value;

    if (story == null || story.title.isEmpty) {
      context.snackbar(AppLocalizations.of(context)!
          .blankStringError(AppLocalizations.of(context)!.title));

      return;
    } else if (body.isEmpty) {
      context.snackbar(AppLocalizations.of(context)!
          .blankStringError(AppLocalizations.of(context)!.body));

      return;
    }

    await state.update(story, body).then((value) => afterSend(context, state));
  }

  void deleteReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();

    await state.delete().then((value) => afterSend(context, state));
  }

  void _goEdit(
    ReviewState review,
  ) async {
    review.edit();
  }

  bool canEdit(ReviewState state, AuthState authState) =>
      !state.isCreate &&
      (state.review != null && authState.sameUser(state.review!.user));

  void _goCopy(ReviewState state) {
    UnimplementedError();
  }

  @override
  Widget build(BuildContext context) => Consumer2<ReviewState, AuthState>(
        builder: (context, state, authState, _) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: StainsAppBar(
            title: AppBarTitle(AppLocalizations.of(context)!.review),
            moreActions: canEdit(state, authState)
                ? [
                    PopupMenuButton<Text>(
                      icon: Icon(Icons.adaptive.more),
                      itemBuilder: (context) => <PopupMenuItem<Text>>[
                        PopupMenuItem(
                          child: Text(
                            AppLocalizations.of(context)!.delete,
                            style: context.labelSmall!
                                .copyWith(color: context.colors.error),
                          ),
                          onTap: () {
                            deleteReview(context);
                          },
                        ),
                      ],
                    ),
                  ]
                : [],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  state.isEdit
                      ? StoryEditWidget(state: state.storyContoller)
                      : StoryWidget(
                          story: state.review?.story,
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReviewUsername(
                        username: state.review?.user.username ??
                            authState.user?.username ??
                            '',
                      ),
                      ReviewDate(
                        date: state.review?.updatedAt ?? DateTime.now(),
                      ),
                    ],
                  ),
                  const Divider(),
                  state.review == null
                      ? Row()
                      : ChangeNotifierProvider(
                          create: (_) =>
                              ReviewEmotionsState(state.review!.emotions),
                          child: const ReviewEmotionsList(),
                        ),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: ReviewBody(),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingButton(context, state, authState),
        ),
      );

  Widget _buildFloatingButton(
    BuildContext context,
    ReviewState state,
    AuthState authState,
  ) =>
      state.isEdit
          ? CustomFloatingButton(
              onPressed: () => editReview(context),
              icon: Icons.send_rounded,
            )
          : canEdit(state, authState)
              ? CustomFloatingButton(
                  onPressed: () async => _goEdit(state),
                  icon: Icons.edit_note,
                )
              : CustomFloatingButton(
                  onPressed: () async => _goCopy(state),
                  icon: Icons.copy,
                );
}
