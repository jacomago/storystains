// ignore_for_file: avoid_classes_with_only_static_members

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/auth.dart';
import '../constant/app_config.dart';
import '../data/network/dio_manager.dart';
import '../data/network/rest_client.dart';

class ServiceLocator {
// Service Locator
  static final sl = GetIt.instance;
  static void setup() {
    final dio = setupDio();
    setupRest(dio);
    setupSecureStorage();
    setupAuth();
  }

  static Dio setupDio() {
    final dioManager = DioManager();
    sl.registerSingleton<DioManager>(dioManager);

    return dioManager.dio;
  }

  static void setupRest(Dio dio) {
    sl.registerLazySingleton<RestClient>(
      () => RestClient(dio, baseUrl: AppConfig.baseUrl),
    );
  }

  static void setupSecureStorage() {
    sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  }

  static void setupAuth() {
    sl.registerSingleton<AuthState>(AuthState(AuthService()));
  }
}
