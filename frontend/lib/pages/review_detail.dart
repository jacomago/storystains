import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/features/review_emotions/review_emotion_list.dart';
import 'package:storystains/features/review_emotions/review_emotions_state.dart';
import 'package:storystains/pages/review_edit.dart';
import 'package:storystains/routes/routes.dart';

class ReviewDetail extends StatelessWidget {
  const ReviewDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReviewArguement;

    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService(), args.review),
      child: const ReviewDetailPage(),
    );
  }
}

class ReviewDetailPage extends StatelessWidget {
  const ReviewDetailPage({Key? key}) : super(key: key);

  _goEdit(BuildContext context, ReviewState review, AuthState authState) async {
    if (authState.isAuthenticated && authState.sameUser(review.review!.user)) {
      Navigator.of(context)
          .push(
            MaterialPageRoute<Review>(
              settings: RouteSettings(
                name: Routes.reviewEdit,
                arguments: ReviewArguement(review.review!),
              ),
              builder: (BuildContext context) {
                return const ReviewEdit();
              },
            ),
          )
          .then(
            (value) async =>
                {value != null ? await review.putReview(value) : context.pop()},
          );
    } else {
      context.snackbar("Must be logged in as creator to edit.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewState, AuthState>(
      builder: (context, review, authState, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: const StainsAppBar(
            title: AppBarTitle('Review'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            review.review?.title ?? '',
                            style: context.headlineSmall,
                            semanticsLabel: 'Title',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUsername(
                        context,
                        review.review!.user.username,
                      ),
                      _buildDate(
                        context,
                        review.review!.updatedAt,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: context.colors.secondary,
                  ),
                  const SizedBox(height: 10),
                  ChangeNotifierProvider(
                    create: (_) => ReviewEmotionsState(review.review!.emotions),
                    child: const ReviewEmotionsList(),
                  ),
                  Divider(
                    color: context.colors.secondary,
                  ),
                  Markdown(
                    physics: const NeverScrollableScrollPhysics(),
                    data: review.review?.body ?? '',
                    selectable: true,
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: CustomFloatingButton(
            onPressed: () async => _goEdit(context, review, authState),
            icon: Icons.edit_note,
          ),
        );
      },
    );
  }

  Widget _buildUsername(BuildContext context, String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "@$username",
          style: context.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          overflow: TextOverflow.fade,
          semanticsLabel: 'Username',
        ),
      ],
    );
  }

  Widget _buildDate(BuildContext context, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMEEEEd().format(date),
          style: context.caption,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: 'Modified Date',
        ),
      ],
    );
  }
}
