import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    bool isItem = index < reviews.count;
                    bool isLastIndex = index == reviews.count;
                    bool isLoadingMore = isLastIndex && reviews.isLoadingMore;

                    // User Item
                    if (isItem) {
                      return _buildReviewItem(context, reviews.item(index));
                    }

                    // Show loading more at the bottom
                    if (isLoadingMore) return const LoadingMore();
// Default empty content
                    return Container();
                  },
                  separatorBuilder: (context, index) => Divider(
                      height: 24, color: context.colors.primaryContainer),
                  itemCount: reviews.count,
                )));
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.reviewDetail,
          arguments: review.slug),
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      review.createdAt,
                      style: context.labelSmall,
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 24),
            Text(review.title, style: context.displaySmall),
            Text(
              review.body,
              style: context.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
