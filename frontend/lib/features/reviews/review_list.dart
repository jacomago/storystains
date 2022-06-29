import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storystains/common/widget/widget.dart';
import 'package:storystains/features/review/review_route.dart';
import 'package:storystains/features/review/widgets/review_date.dart';
import 'package:storystains/features/review/widgets/review_username.dart';
import 'package:storystains/features/review_emotions/review_emotions.dart';
import 'package:storystains/features/review/review_model.dart';
import 'package:storystains/pages/review_detail.dart';
import 'package:storystains/routes/routes.dart';

import 'reviews_state.dart';
import 'package:storystains/common/utils/extensions.dart';

class ReviewList extends StatelessWidget {
  const ReviewList({Key? key}) : super(key: key);

  void _afterPush(BuildContext context) {
    final state = context.read<ReviewsState>();
    state.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsState>(
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
          ),
        );
      },
    );
  }

  _tapItem(BuildContext context, Review review) {
    Navigator.of(context)
        .push(
          ReviewRoute.route(
            Routes.reviewDetail,
            review,
            (r) => ReviewDetail(
              review: r,
            ),
          ),
        )
        .then((value) => _afterPush(context));
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return Column(
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
                  child: _buildTitle(context, review.title),
                ),
                ChangeNotifierProvider(
                  create: (_) => ReviewEmotionsState(review.emotions),
                  child: const CardReviewEmotionsList(),
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
                  padding: const EdgeInsets.symmetric(vertical: 0),
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
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Column(
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
}
