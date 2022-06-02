import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/constant/app_colors.dart';
import '../../common/constant/app_size.dart';
import '../../common/widget/app_bar.dart';

import 'logic.dart';

class ReviewPostPage extends GetView<ReviewPostLogic> {
  const ReviewPostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PageBar(
        context: context,
        title: 'New Review',
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSize.w_16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSize.w_24),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                    hintText: 'Review title',
                  ),
                  style: TextStyle(
                    color: AppColors.app_383A3C,
                    fontSize: AppSize.s_32,
                    fontWeight: FontWeight.bold,
                  ),
                  controller: controller.titleController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSize.w_24),
                child: TextField(
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    hintText: 'Write your review (in markdown)',
                  ),
                  style: TextStyle(
                    color: AppColors.app_383A3C,
                    fontSize: AppSize.s_28,
                  ),
                  controller: controller.bodyController,
                  minLines: 5,
                  maxLines: 50,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.postReview(),
        backgroundColor: AppColors.main,
        child: Icon(
          Icons.send_rounded,
          size: AppSize.w_48,
          color: AppColors.white,
        ),
      ),
    );
  }
}
