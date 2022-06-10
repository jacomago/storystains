import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:storystains/pages/review_edit.dart';
import 'package:storystains/routes/routes.dart';
import 'package:storystains/utils/extensions.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewState>(
      builder: (context, review, _) {
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
                  Text(
                    review.review?.title ?? '',
                    style: context.displayMedium,
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
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
            onPressed: () async => Navigator.of(context)
                .push(
                  MaterialPageRoute<Review>(
                      settings: RouteSettings(
                          name: Routes.reviewEdit,
                          arguments: ReviewArguement(review.review!)),
                      builder: (BuildContext context) {
                        return const EditReview();
                      }),
                )
                .then((value) async => await review.putReview(value!)),
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
