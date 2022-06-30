import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/data/network/dio_manager.dart';
import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/features/auth/auth.dart';

// Service Locator
final sl = GetIt.instance;

class ServiceLocator {
  static void setup() {
    final dioManager = DioManager();
    sl.registerSingleton<DioManager>(dioManager);
    sl.registerLazySingleton<RestClient>(
      () => RestClient(dioManager.dio, baseUrl: AppConfig.baseUrl),
    );
    sl.registerSingleton<AuthState>(AuthState(AuthService()));
    sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  }
}
