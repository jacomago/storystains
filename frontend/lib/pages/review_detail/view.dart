import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/constant/app_colors.dart';
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
                        style: TextStyle(
                          color: AppColors.main,
                          fontSize: AppSize.s_48,
                        ),
                      ),
                      SizedBox(height: AppSize.w_24),
                      _genAuthor(),
                      SizedBox(height: AppSize.w_24),
                      Markdown(
                        physics: const NeverScrollableScrollPhysics(),
                        data: controller.state.body ?? '',
                        selectable: true,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        // style: TextStyle(
                        //   color: AppColors.app_383A3C,
                        //   fontSize: AppSize.s_32,
                        //   fontStyle: FontStyle.italic,
                        // ),
                      ),
                      Divider(height: AppSize.w_48),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _genAuthor() {
    return Row(
      children: [
        SizedBox(width: AppSize.w_12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSize.w_8),
            Text(
              DateFormat.yMMMMEEEEd().format(
                  DateTime.tryParse(controller.state.review.value!.createdAt)!),
              style: TextStyle(
                color: AppColors.app_989898,
                fontSize: AppSize.s_18,
              ),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(width: AppSize.w_24),
        SizedBox(width: AppSize.w_2),
      ],
    );
  }
}
