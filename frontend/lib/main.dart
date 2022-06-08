import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:storystains/common/constant/app_theme.dart';
import 'package:storystains/pages/pages.dart';
import 'package:universal_platform/universal_platform.dart';

import 'common/util/init_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (UniversalPlatform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark),
    );
  }

  getItSetUp();
  InitUtils.init().then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: lightColorScheme,
      ),
      initialRoute: Pages.home,
      getPages: Pages.all,
      scrollBehavior: MobileAndDesktopBehavior(),
    );
  }
}

class MobileAndDesktopBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
