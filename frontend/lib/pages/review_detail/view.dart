import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';
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
                padding: EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.state.reviewTitle ?? '',
                        style: context.displayMedium,
                      ),
                      SizedBox(height: 24),
                      SizedBox(height: 24),
                      Markdown(
                        physics: const NeverScrollableScrollPhysics(),
                        data: controller.state.body ?? '',
                        selectable: true,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                      ),
                      Divider(height: 48),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => () async {
          await Get.toNamed(Pages.editReview,
              arguments: controller.state.review.value);
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
