import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/data/network/dio_manager.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/auth/auth.dart';

final interceptors = [
  CancelInterceptors(),
  AuthInterceptors(),
  LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    logPrint: (msg) => log(msg.toString(), name: 'HTTP'),
  ),
];

class CancelInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    sl.get<DioManager>().addToken(
          options.cancelToken ??= sl.get<DioManager>().defaultCancelToken,
        );
    handler.next(options);
  }
}

class AuthInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final uri = options.uri;
    final authState = sl.get<AuthState>();
    await authState.init();
    if (AppConfig.baseUrl.startsWith("${uri.scheme}://${uri.host}") &&
        authState.isAuthenticated) {
      options.headers['authorization'] = 'Bearer ${authState.token}';
    }
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final uri = response.requestOptions.uri;
    if (AppConfig.baseUrl.startsWith("${uri.scheme}://${uri.host}") &&
        response.statusCode == 401) {
      await sl.get<AuthState>().logout();
    } else {
      handler.next(response);
    }
  }
}
