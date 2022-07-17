// ignore_for_file: avoid_classes_with_only_static_members

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/auth.dart';
import '../constant/app_config.dart';
import '../data/network/dio_manager.dart';
import '../data/network/rest_client.dart';
import 'cookie_storage.dart';

/// Locator of services which should always be availble, such as auth and
/// the rest client
class ServiceLocator {
  /// Service Locator
  static final sl = GetIt.instance;

  /// Sets up the [GetIt] service locator
  static void setup() {
    final cookieJar = kIsWeb ? null : setupSecureStorage();
    final dio = setupDio(cookieJar);
    setupRest(dio);
    setupAuth();
  }

  /// Sets up [DioManager] in the service locator
  static Dio setupDio([PersistCookieJar? cookieJar]) {
    final dioManager = DioManager(cookieJar);
    sl.registerSingleton<DioManager>(dioManager);

    return dioManager.dio;
  }

  /// Sets up the [RestClient] in the service locator
  static void setupRest(Dio dio) {
    sl.registerLazySingleton<RestClient>(
      () => RestClient(dio, baseUrl: AppConfig.baseUrl),
    );
  }

  /// Sets up [PersistCookieJar] in the service locator
  static PersistCookieJar setupSecureStorage() {
    final cookieJar = PersistCookieJar(
      storage: CookieStorage(
        const FlutterSecureStorage(
          aOptions: CookieStorage.aOptions,
        ),
      ),
    );
    sl.registerSingleton<PersistCookieJar>(cookieJar);

    return cookieJar;
  }

  /// Sets up [AuthState] in the service locator
  static void setupAuth() {
    sl.registerSingleton<AuthState>(AuthState(AuthService()));
  }
}
