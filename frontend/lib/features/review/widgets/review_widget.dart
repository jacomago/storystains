import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../auth/auth.dart';
import '../../mediums/medium.dart';
import '../../review_emotions/review_emotions.dart';
import '../../story/story.dart';
import '../../user/user_model.dart';
import '../review.dart';
import 'review_body.dart';

/// Actions currently available
enum EditAction {
  /// Send to the api the new update
  send,

  /// Swap to editing the [Review]
  edit,

  /// Swap to a new review with the same Story
  copy,

  /// No action available
  none
}

/// Widget to display or edit a [Review]
class ReviewWidget extends StatelessWidget {
  /// Widget to display or edit a [Review]
  const ReviewWidget({Key? key}) : super(key: key);

  void _afterSend(BuildContext context, ReviewState state) {
    if (state.isUpdated) {
      context.pop(state.review);
      context.snackbar(context.locale.updatedObject(context.locale.review));
    } else if (state.isDeleted) {
      context.pop();
      context.snackbar(context.locale.deletedObject(context.locale.review));
    } else {
      if (state.isFailed) {
        context.snackbar(state.error);
      } else {
        context.snackbar(context.locale.pleaseTryAgain);
      }
    }
  }

  void _editReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();
    final body = state.bodyController.value.text.isEmpty
        ? null
        : state.bodyController.value.text;
    final story = state.storyController.value;

    if (story.title.isEmpty ||
        story.creator.isEmpty ||
        story.medium.name.isEmpty) {
      context.snackbar(context.locale.blankStringError(context.locale.story));

      return;
    }

    await state.update(story, body).then((value) => _afterSend(context, state));
  }

  void _deleteReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();

    await state.delete().then((value) => _afterSend(context, state));
  }

  void _goEdit(
    ReviewState review,
  ) async {
    review.edit();
  }

  EditAction _currentAction(ReviewState state, AuthState authState) {
    if (authState.notAuthenticated) {
      return EditAction.none;
    }
    if (state.isEdit) return EditAction.send;
    if (state.review != null && authState.sameUser(state.review!.user)) {
      return EditAction.edit;
    }

    return EditAction.copy;
  }

  List<Widget> _buildDelete(
    BuildContext context,
    ReviewState state,
    AuthState authState,
  ) =>
      _currentAction(state, authState) == EditAction.edit
          ? [
              PopupMenuButton<Text>(
                icon: Icon(Icons.adaptive.more),
                itemBuilder: (context) => <PopupMenuItem<Text>>[
                  PopupMenuItem(
                    child: Text(
                      context.locale.delete,
                      style: context.labelSmall!
                          .copyWith(color: context.colors.error),
                    ),
                    onTap: () {
                      _deleteReview(context);
                    },
                  ),
                ],
              ),
            ]
          : [];

  void _goCopy(
    ReviewState state,
    AuthState authState,
  ) async {
    await state.copy(authState.user!.username);
  }

  @override
  Widget build(BuildContext context) => Consumer2<ReviewState, AuthState>(
        builder: (context, state, authState, _) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: StainsAppBar(
            title: AppBarTitle(context.locale.review),
            moreActions: _buildDelete(context, state, authState),
          ),
          bottomNavigationBar: const NavBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  state.isEdit
                      ? StoryEditWidget(state: state.storyController)
                      : StoryWidget(
                          story: state.review?.story ??
                              Story(
                                title: '',
                                medium: Medium.mediumDefault,
                                creator: '',
                              ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReviewUsername(
                        user: state.review?.user ??
                            authState.userProfile ??
                            UserProfile(username: ''),
                      ),
                      ReviewDate(
                        date: state.review?.updatedAt ?? DateTime.now(),
                      ),
                    ],
                  ),
                  const Divider(),
                  state.isCreate
                      ? Row()
                      : ReviewEmotionsList(
                          state: state.reviewEmotionsController,
                        ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.locale.body,
                          style: context.labelLarge,
                        ),
                        const Divider(),
                        const ReviewBody(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingButton(context, state, authState),
        ),
      );

  Widget? _buildFloatingButton(
    BuildContext context,
    ReviewState state,
    AuthState authState,
  ) {
    switch (_currentAction(state, authState)) {
      case EditAction.send:
        return CustomFloatingButton(
          onPressed: () => _editReview(context),
          icon: Icons.send_rounded,
        );
      case EditAction.edit:
        return CustomFloatingButton(
          onPressed: () async => _goEdit(state),
          icon: Icons.edit_note,
        );
      case EditAction.copy:
        return CustomFloatingButton(
          onPressed: () async => _goCopy(state, authState),
          icon: Icons.copy,
        );
      case EditAction.none:
        return null;
    }
  }
}
