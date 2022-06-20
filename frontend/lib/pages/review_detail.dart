import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/auth/auth.dart';
import 'package:storystains/features/review_emotions/review_emotion_list.dart';
import 'package:storystains/features/review_emotions/review_emotions_state.dart';
import 'package:storystains/pages/review_edit.dart';
import 'package:storystains/routes/routes.dart';

import '../features/review/review.dart';
import '../model/entity/review.dart';

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
                return const EditReview();
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
          appBar: AppBar(
            title: const Text("Review"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
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
                            style: context.displayMedium,
                            semanticsLabel: 'Title',
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(
                            height: 4.0,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "@${review.review?.user.username ?? ''}",
                            style: context.titleMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                            semanticsLabel: 'Username',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Created At: ${DateFormat.yMMMMEEEEd().format(review.review!.createdAt)}",
                            style: context.caption,
                            overflow: TextOverflow.ellipsis,
                            semanticsLabel: 'Creation Date',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Updated At: ${DateFormat.yMMMMEEEEd().format(review.review!.updatedAt)}",
                            style: context.caption,
                            overflow: TextOverflow.ellipsis,
                            semanticsLabel: 'Modified Date',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ChangeNotifierProvider(
                    create: (_) => ReviewEmotionsState(review.review!.emotions),
                    child: const ReviewEmotionsList(),
                  ),
                  Markdown(
                    physics: const NeverScrollableScrollPhysics(),
                    data: review.review?.body ?? '',
                    selectable: true,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                  ),
                  const Divider(height: 48),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async => _goEdit(context, review, authState),
            backgroundColor: context.colors.primary,
            child: Icon(
              Icons.edit,
              color: context.colors.onBackground,
            ),
          ),
        );
      },
    );
  }
}
