import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/constant/app_colors.dart';
import '../../common/constant/app_size.dart';
import '../../common/util/screen_adapter.dart';
import '../../common/widget/app_bar.dart';
import '../../common/widget/avatar_image.dart';
import '../../common/widget/review_list.dart';
import '../pages.dart';
import 'logic.dart';

class HomePage extends GetView<HomeLogic> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
      appBar: PageBar(
        context: context,
        leftMenu: Text(
          'conduit',
          style: TextStyle(
            color: AppColors.main,
            fontSize: AppSize.s_48,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightMenu: GetBuilder<HomeLogic>(
            id: 'rightMenu',
            builder: (c) => c.state.isLogin
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => c.goProfile(),
                    child: AvatarImage(
                      url: null,
                      hasBorder: true,
                    ),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => c.login(),
                    child: Icon(
                      Icons.login_rounded,
                      size: AppSize.w_48,
                      color: AppColors.main,
                    ),
                  )),
      ),
      body: ReviewsPage(controller: controller.listController),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Pages.newReview),
        backgroundColor: AppColors.main,
        child: Icon(
          Icons.add_rounded,
          size: AppSize.w_56,
          color: AppColors.white,
        ),
      ),
    );
  }
}
