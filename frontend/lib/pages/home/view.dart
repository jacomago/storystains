import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storystains/common/extensions.dart';
import '../../common/widget/app_bar.dart';
import '../../common/widget/review_list.dart';
import '../pages.dart';
import 'logic.dart';

class HomePage extends GetView<HomeLogic> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageBar(
        context: context,
        leftMenu: Text(
          'Story Stains',
          style: context.displayLarge,
        ),
        rightMenu: GetBuilder<HomeLogic>(
            id: 'rightMenu',
            builder: (c) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => c.login(),
                  child: Icon(
                    Icons.login_rounded,
                    size: 48,
                    color: context.colors.primary,
                  ),
                )),
      ),
      body: ReviewsPage(controller: controller.listController),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Pages.newReview),
        backgroundColor: context.colors.primary,
        child: Icon(
          Icons.add_rounded,
          size: 56,
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}
