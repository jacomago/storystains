import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:storystains/common/extensions.dart';

class ToastUtils {
  static showError(dynamic e) {
    if (e is DioError) {
      show(e.message);
    } else {
      show(e.toString());
    }
  }

  static show(String text) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: text,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      // it may not show toast. see: https://github.com/flutter/flutter/issues/30294
      final context = Get.context!;
      FToast().init(context).showToast(
            child: Container(
              constraints: BoxConstraints.loose(Size(700, 64)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: context.colors.background,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: context.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
    }
  }
}
