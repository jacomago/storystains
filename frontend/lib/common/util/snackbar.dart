import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtils {
  static showError(dynamic e) {
    if (e is DioError) {
      show(e.message);
    } else {
      show(e.toString());
    }
  }

  static show(String text) {
    // it may not show toast. see: https://github.com/flutter/flutter/issues/30294
    final context = Get.context!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
