import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:storystains/config/config.dart';
import 'package:storystains/modules/reviews/reviews.dart';
import 'package:storystains/widgets/error.dart';
import 'package:storystains/widgets/loading_more.dart';
import 'package:storystains/widgets/review_item.dart';

class Reviews extends StatelessWidget {
  const Reviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsState(ReviewsService()),
      child: const ReviewsPage(),
    );
  }
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Reviews'),
      ),
      body: Consumer<ReviewsState>(
        builder: (_, reviews, __) {
          if (reviews.isFailed) {
            return ErrorMessage(failed, onRefresh: reviews.refresh);
          }

          if (reviews.isEmpty) {
            return ErrorMessage(empty, onRefresh: reviews.refresh);
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
              itemCount: reviews.count + 1,
              itemBuilder: (_, index) {
                bool isItem = index < reviews.count;
                bool isLastIndex = index == reviews.count;
                bool isLoadingMore = isLastIndex && reviews.isLoadingMore;

                // Review Item
                if (isItem) return ReviewItem(reviews.item(index));

                // Show loading more at the bottom
                if (isLoadingMore) return const LoadingMore();

                // Default empty content
                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}
