import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/http/dio_manager.dart';
import 'package:storystains/common/util/auth_manager.dart';
import 'package:storystains/common/util/storage.dart';

import 'package:get_it/get_it.dart';
import 'package:storystains/services/rest_client.dart';

class InitUtils {
  static Future<void> init() async {
    await Storage.init();
  }
}

GetIt sl = GetIt.instance;

void getItSetUp() {
  final dioManager = DioManager();
  sl.registerSingleton<DioManager>(dioManager);
  sl.registerSingleton<RestClient>(
      RestClient(dioManager.dio, baseUrl: AppConfig.baseUrl));
  sl.registerSingleton<AuthManager>(AuthManager());
}
