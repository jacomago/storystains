import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../../auth/auth.dart';
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

  void _editReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final state = context.read<ReviewState>();
    final body = state.bodyController.value.text;
    final story = state.storyController.value;

    if (story == null || story.title.isEmpty) {
      context.snackbar(AppLocalizations.of(context)!
          .blankStringError(AppLocalizations.of(context)!.title));

      return;
    } else if (body.isEmpty) {
      context.snackbar(AppLocalizations.of(context)!
          .blankStringError(AppLocalizations.of(context)!.body));

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
    if (authState.notAuthenticated || state.review == null) {
      return EditAction.none;
    }
    if (state.isEdit) return EditAction.send;
    if (authState.sameUser(state.review!.user)) return EditAction.edit;

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
                      AppLocalizations.of(context)!.delete,
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
            title: AppBarTitle(AppLocalizations.of(context)!.review),
            moreActions: _buildDelete(context, state, authState),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  state.isEdit
                      ? StoryEditWidget(state: state.storyController)
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
