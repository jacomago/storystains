import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/util/init_utils.dart';
import '../../common/util/loading_dialog.dart';
import '../../common/util/snackbar.dart';
import '../../model/req/create_review.dart';
import '../../model/resp/review_resp.dart';
import '../../pages/pages.dart';

import '../../services/rest_client.dart';
import 'state.dart';

class ReviewPostLogic extends GetxController {
  final ReviewPostState state = ReviewPostState();

  var titleController = TextEditingController();
  var bodyController = TextEditingController();

  @override
  void onClose() {
    super.onClose();
    titleController.dispose();
    bodyController.dispose();
  }

  Future<void> postReview() async {
    final body = bodyController.value.text;
    final title = titleController.value.text;
    if (title.isEmpty) {
      SnackBarUtil.show('Title can\'t be blank');
      return;
    } else if (body.isEmpty) {
      SnackBarUtil.show('Content can\'t be blank');
      return;
    }
    LoadingDialog.show();
    var result = false;
    ReviewResp? postResp;
    try {
      postResp = await sl<RestClient>().createReview(CreateReview(
        review: NewReview(
          body: body,
          title: title,
        ),
      ));
      result = true;
    } catch (e, stackTrace) {
      log(stackTrace.toString());
      SnackBarUtil.showError(e);
    } finally {
      LoadingDialog.hide();
    }
    if (result && postResp != null) {
      Get.offNamed(Pages.reviewDetail, arguments: postResp.review);
    }
  }
}
