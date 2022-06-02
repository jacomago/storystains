import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:storystains/common/extensions.dart';

class LoadingDialog {
  static BuildContext? dialogContext;

  static hide({bool isAwait = false}) async {
    if (dialogContext == null && !isAwait) {
      await Future.delayed(const Duration(milliseconds: 200));
      hide(isAwait: true);
      return;
    }

    bool isActive = false;
    try {
      RenderObject? object = dialogContext?.findRenderObject();
      isActive = object != null;
    } catch (e) {
      log('loading context is inActive $e');
      isActive = false;
    }
    if (dialogContext != null && isActive) {
      Navigator.of(dialogContext!).pop();
      dialogContext = null;
    }
  }

  static show() {
    Get.dialog(
        DialogWrapper(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              // padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: OverflowBox(
                minHeight: 240,
                maxHeight: 240,
                minWidth: 240,
                maxWidth: 240,
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        )),
        useSafeArea: false,
        barrierDismissible: false,
        barrierColor: Get.context!.colors.primaryContainer);
  }
}

class DialogWrapper extends StatelessWidget {
  final Widget child;

  const DialogWrapper({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoadingDialog.dialogContext = context;
    return Container(
      width: Get.width,
      height: Get.height,
      color: context.colors.surfaceTint,
      child: child,
    );
  }
}
