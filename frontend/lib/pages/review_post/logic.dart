import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/util/loading_dialog.dart';
import '../../common/util/toast_utils.dart';
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
      ToastUtils.show('Title can\'t be blank');
      return;
    } else if (body.isEmpty) {
      ToastUtils.show('Content can\'t be blank');
      return;
    }
    LoadingDialog.show();
    var result = false;
    ReviewResp? postResp;
    try {
      postResp = await RestClient.client.createReview(CreateReview(
        review: NewReview(
          body: body,
          title: title,
        ),
      ));
      result = true;
    } catch (e, stackTrace) {
      log(stackTrace.toString());
      ToastUtils.showError(e);
    } finally {
      LoadingDialog.hide();
    }
    if (result && postResp != null) {
      Get.offNamed(Pages.reviewDetail, arguments: postResp.review);
    }
  }
}