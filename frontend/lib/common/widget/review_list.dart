import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/entity/review.dart';
import '../../pages/pages.dart';
import '../../services/rest_client.dart';
import '../constant/app_colors.dart';
import '../constant/app_size.dart';
import '../util/toast_utils.dart';
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
      padding: EdgeInsets.symmetric(vertical: AppSize.w_24),
      child: LoadWrapper<Review>(
        controller: widget.controller,
        child: ListView.separated(
          itemBuilder: (context, index) => _buildReviewItem(reviews[index]),
          separatorBuilder: (context, index) =>
              Divider(height: AppSize.w_24, color: Colors.transparent),
          itemCount: reviews.length,
        ),
        pageService: (offset, limit) => fetchReviews(offset, limit),
        onPageLoaded: (list) => setState(() => reviews = list),
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return GestureDetector(
      onTap: () => Get.toNamed(Pages.reviewDetail, arguments: review),
      child: Container(
        padding: EdgeInsets.all(AppSize.w_24),
        margin: EdgeInsets.symmetric(horizontal: AppSize.w_24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppSize.w_24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: AppSize.w_12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSize.w_8),
                    Text(
                      DateFormat.yMMMMEEEEd()
                          .format(DateTime.tryParse(review.createdAt)!),
                      style: TextStyle(
                        color: AppColors.app_989898,
                        fontSize: AppSize.s_18,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: AppSize.w_24),
            Text(
              review.title,
              style: TextStyle(
                color: AppColors.app_383A3C,
                fontSize: AppSize.s_36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              review.body,
              style: TextStyle(
                color: AppColors.app_808080,
                fontSize: AppSize.s_28,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSize.w_24),
          ],
        ),
      ),
    );
  }

  Future<List<Review>> fetchReviews([int offset = 0, int limit = 10]) async {
    try {
      final resp = await RestClient.client.getReviews(
        offset: offset,
        limit: limit,
      );
      return resp.reviews;
    } catch (e) {
      ToastUtils.showError(e);
      return [];
    }
  }

}
