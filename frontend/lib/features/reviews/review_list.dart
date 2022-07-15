import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../common/utils/extensions.dart';
import '../../common/widget/widget.dart';
import '../../pages/review_detail.dart';
import '../../routes/routes.dart';
import '../review/review.dart';
import '../story/story.dart';
import 'reviews_state.dart';

/// Widget for displaying a list of [Review]
class ReviewList extends StatelessWidget {
  /// Widget for displaying a list of [Review]
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
              AppLocalizations.of(context)!
                  .actionFailed(AppLocalizations.of(context)!.dataFetch),
              onRefresh: reviews.refresh,
            );
          }

          if (reviews.isEmpty) {
            return LoadMessage(
              AppLocalizations.of(context)!.noData,
              onRefresh: reviews.refresh,
            );
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
          review.route(
            Routes.reviews,
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
                    child: StoryItem(story: review.story),
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
}
