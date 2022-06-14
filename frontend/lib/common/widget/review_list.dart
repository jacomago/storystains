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
import 'load_message.dart';
import 'loading_more.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsState>(
      builder: (_, reviews, __) {
        if (reviews.isFailed) {
          return LoadMessage('Fetching data failed',
              onRefresh: reviews.refresh);
        }

        if (reviews.isEmpty) {
          return LoadMessage('No data', onRefresh: reviews.refresh);
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
        onTap: () => context.push(Routes.reviewDetail,
            arguments: ReviewArguement(review)),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Card(
                color: context.colors.primaryContainer,
                elevation: 8.0,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    height: 125,
                    width: 350,
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
                                Text(review.title,
                                    style: context.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(review.body,
                                    style: context.bodyMedium,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            )
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
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(height: 4),
                                Text(review.user.username,
                                    style: context.bodySmall
                                        ?.copyWith(fontStyle: FontStyle.italic),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                    DateFormat.yMMMMEEEEd()
                                        .format(review.updatedAt),
                                    style: context.caption,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            )
                          ],
                        )
                      ],
                    )))));
  }
}
