import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storystains/utils/navigation.dart';

import '../../features/review/review.dart';
import '../../features/reviews/reviews_state.dart';
import '../../model/entity/review.dart';
import 'package:storystains/utils/extensions.dart';

import '../../routes/routes.dart';
import 'error.dart';
import 'loading_more.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsState>(
      builder: (_, reviews, __) {
        if (reviews.isFailed) {
          return ErrorMessage('Fetching data failed',
              onRefresh: reviews.refresh);
        }

        if (reviews.isEmpty) {
          return ErrorMessage('No data', onRefresh: reviews.refresh);
        }

        if (reviews.isLoadingFirst) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: RefreshIndicator(
                onRefresh: reviews.refresh,
                child: ScrollablePositionedList.builder(
                  itemScrollController: reviews.itemScrollController,
                  itemPositionsListener: reviews.itemPositionsListener,
                  itemBuilder: (context, index) {
                    bool isItem = index < reviews.count;
                    bool isLastIndex = index == reviews.count;
                    bool isLoadingMore = isLastIndex && reviews.isLoadingMore;

                    // Review Item
                    if (isItem) {
                      return _buildReviewItem(context, reviews.item(index));
                    }

                    // Show loading more at the bottom
                    if (isLoadingMore) return const LoadingMore();

                    // Default empty content
                    return Container();
                  },
                  itemCount: reviews.count,
                )));
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return GestureDetector(
      onTap: () =>
          context.push(Routes.reviewDetail, arguments: ReviewArguement(review)),
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        review.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                      Text(
                        review.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        review.user.username,
                        style: context.bodySmall,
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd().format(review.updatedAt),
                        style: context.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
