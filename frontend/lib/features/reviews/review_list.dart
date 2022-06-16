import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storystains/common/utils/navigation.dart';

import '../review/review.dart';
import 'reviews_state.dart';
import '../../model/entity/review.dart';
import 'package:storystains/common/utils/extensions.dart';

import '../../routes/routes.dart';
import '../../common/widget/load_message.dart';
import '../../common/widget/loading_more.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

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
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return GestureDetector(
      onTap: () =>
          context.push(Routes.reviewDetail, arguments: ReviewArguement(review)),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Card(
          color: context.colors.primaryContainer,
          elevation: 8.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            height: 125,
            width: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(context, review.title),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUsername(context, review.user.username),
                    _buildDate(context, review.updatedAt),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          title,
          style: context.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildUsername(BuildContext context, String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          username,
          style: context.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          overflow: TextOverflow.ellipsis,
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
        ),
      ],
    );
  }
}
