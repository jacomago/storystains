import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:storystains/pages/review_edit/view.dart';
import 'package:storystains/routes/routes.dart';
import 'package:storystains/utils/extensions.dart';
import '../../common/widget/app_bar.dart';

import '../pages.dart';
import 'logic.dart';

class ReviewDetailPage extends GetView<ReviewDetailLogic> {
  ReviewDetailPage({Key? key}) : super(key: key);

  final String _tag = Get.arguments.toString();

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PageBar(
        context: context,
      ),
      body: Obx(
        () => controller.state.review.value == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.state.reviewTitle ?? '',
                        style: context.displayMedium,
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                      Markdown(
                        physics: const NeverScrollableScrollPhysics(),
                        data: controller.state.body ?? '',
                        selectable: true,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                      ),
                      const Divider(height: 48),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.reviewEdit,
              arguments: ReviewArguement(review.slug));
        },
        backgroundColor: context.colors.primary,
        child: Icon(
          Icons.edit,
          color: context.colors.onBackground,
        ),
      ),
    );
  }
}
