

import 'package:storystains/common/util/auth_manager.dart';
import 'package:storystains/common/util/storage.dart';

class InitUtils{
  static Future<void> init() async {
    await Storage.init();
    await AuthManager.init();
  }
}