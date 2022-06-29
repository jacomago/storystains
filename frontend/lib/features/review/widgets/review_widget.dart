import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/review/widgets/review_title.dart';
import 'package:storystains/features/review_emotions/review_emotions.dart';

import 'review_body.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({Key? key}) : super(key: key);

  void afterSend(BuildContext context, ReviewState state) {
    if (state.isUpdated) {
      context.pop(state.review);
      const msg = 'Updated Review';
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

  void _goEdit(
    ReviewState review,
  ) async {
    review.edit();
  }

  bool canEdit(ReviewState state, AuthState authState) {
    return !state.isCreate &&
        (state.review != null && authState.sameUser(state.review!.user));
  }

  _goCopy(ReviewState state) {
    UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewState, AuthState>(
      builder: (context, state, authState, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: StainsAppBar(
            title: const AppBarTitle('Review'),
            moreActions: canEdit(state, authState)
                ? []
                : [
                    PopupMenuButton<Text>(
                      icon: Icon(Icons.adaptive.more),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<Text>>[
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
                  const ReviewTitle(),
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
        );
      },
    );
  }

  Widget _buildFloatingButton(
    BuildContext context,
    ReviewState state,
    AuthState authState,
  ) {
    return state.isEdit
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
}
