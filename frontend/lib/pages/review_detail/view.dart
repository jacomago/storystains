import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';
import '../../common/constant/app_size.dart';
import '../../common/widget/app_bar.dart';

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
                padding: EdgeInsets.all(AppSize.w_24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.state.reviewTitle ?? '',
                        style: context.displayMedium,
                      ),
                      SizedBox(height: AppSize.w_24),
                      SizedBox(height: AppSize.w_24),
                      Markdown(
                        physics: const NeverScrollableScrollPhysics(),
                        data: controller.state.body ?? '',
                        selectable: true,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                      ),
                      Divider(height: AppSize.w_48),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

}
