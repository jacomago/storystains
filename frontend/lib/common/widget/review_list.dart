import 'package:flutter/material.dart';
import 'package:storystains/utils/navigation.dart';

import '../../model/entity/review.dart';
import 'package:storystains/utils/extensions.dart';

import '../../routes/routes.dart';
import 'load_wrapper.dart';


class ReviewsPage extends StatefulWidget {
  final String? author;
  final String? tag;
  final String? favoriteBy;
  final LoadController? controller;

  const ReviewsPage({
    Key? key,
    this.author,
    this.tag,
    this.favoriteBy,
    this.controller,
  }) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  var reviews = <Review>[];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: LoadWrapper<Review>(
        controller: widget.controller,
        child: ListView.separated(
          itemBuilder: (context, index) => _buildReviewItem(reviews[index]),
          separatorBuilder: (context, index) =>
              Divider(height: 24, color: context.colors.primaryContainer),
          itemCount: reviews.length,
        ),
        pageService: (offset, limit) => fetchReviews(offset, limit),
        onPageLoaded: (list) => setState(() => reviews = list),
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return GestureDetector(
      onTap: () => context.push(Routes.reviewDetail, arguments: review),
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

  Future<List<Review>> fetchReviews([int offset = 0, int limit = 10]) async {
    try {
      final resp = await sl<RestClient>().getReviews(
        offset: offset,
        limit: limit,
      );
      return resp.reviews;
    } catch (e) {
      SnackBarUtil.showError(e);
      return [];
    }
  }
}
