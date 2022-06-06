import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/util/loading_dialog.dart';
import '../../common/util/snackbar.dart';
import '../../model/req/create_review.dart';
import '../../model/resp/review_resp.dart';
import '../../pages/pages.dart';

import '../../services/rest_client.dart';
import 'state.dart';

class ReviewEditLogic extends GetxController {
  final ReviewEditState state = ReviewEditState();

  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  var slug = '';

  @override
  void onReady() {
    super.onReady();
    try {
      state.review(Get.arguments);
      titleController.text = state.review.value?.title ?? '';
      bodyController.text = state.review.value?.body ?? '';
      slug = state.review.value?.slug ?? '';
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void onClose() {
    super.onClose();
    titleController.dispose();
    bodyController.dispose();
  }

  Future<void> editReview() async {
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
    ReviewResp? editResp;
    try {
      editResp = await RestClient.client.updateReview(
          slug,
          CreateReview(
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
    if (result && editResp != null) {
      Get.offNamed(Pages.reviewDetail, arguments: editResp.review);
    }
  }
}
