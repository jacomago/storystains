import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../common/utils/extensions.dart';
import '../../common/widget/widget.dart';
import '../../pages/review_detail.dart';
import '../../routes/routes.dart';
import '../review/review_model.dart';
import '../review/review_route.dart';
import '../review/widgets/review_date.dart';
import '../review/widgets/review_username.dart';
import 'reviews_state.dart';

class ReviewList extends StatelessWidget {
  const ReviewList({Key? key}) : super(key: key);

  void _afterPush(BuildContext context) {
    final state = context.read<ReviewsState>();
    state.refresh();
  }

  @override
  Widget build(BuildContext context) => Consumer<ReviewsState>(
        builder: (_, reviews, __) {
          if (reviews.isFailed) {
            return LoadMessage(
              'Fetching data failed',
              onRefresh: reviews.refresh,
            );
          }

          if (reviews.isEmpty) {
            return LoadMessage('No data', onRefresh: reviews.refresh);
          }

          if (reviews.isLoadingFirst) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: reviews.refresh,
            child: ScrollablePositionedList.builder(
              itemScrollController: reviews.itemScrollController,
              itemPositionsListener: reviews.itemPositionsListener,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var isItem = index < reviews.count;
                var isLastIndex = index == reviews.count;
                var isLoadingMore = isLastIndex && reviews.isLoadingMore;

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
            ),
          );
        },
      );

  void _tapItem(BuildContext context, Review review) {
    Navigator.of(context)
        .push(
          ReviewRoutePath(review.slug, review.user.username).route(
            Routes.reviewDetail,
            review,
            (r) => ReviewDetail(
              review: r,
            ),
          ),
        )
        .then((value) => _afterPush(context));
  }

  Widget _buildReviewItem(BuildContext context, Review review) => Column(
        children: [
          GestureDetector(
            onTap: () => _tapItem(context, review),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _buildTitle(context, review.story.title),
                  ),
                  CardReviewEmotionsList(
                    items: review.emotions,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReviewUsername(username: review.user.username),
                      ReviewDate(date: review.updatedAt),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(),
                    child: Divider(
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildTitle(BuildContext context, String title) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            title,
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 4),
        ],
      );
}
