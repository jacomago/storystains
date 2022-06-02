import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenAdapter {
  static var hasInit = false;

  static init(BuildContext context) {
    if (hasInit) return;
    ScreenUtil.init(
      context,
      designSize: const Size(750, 1334),
    );
    hasInit = true;
  }
}
