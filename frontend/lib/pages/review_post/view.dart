import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';
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
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                    hintText: 'Review title',
                  ),
                  style: context.headlineMedium,
                  controller: controller.titleController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: TextField(
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    hintText: 'Write your review (in markdown)',
                  ),
                  style: context.bodySmall,
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
        backgroundColor: context.colors.primary,
        child: Icon(
          Icons.send_rounded,
          color: context.colors.onBackground,
        ),
      ),
    );
  }
}
