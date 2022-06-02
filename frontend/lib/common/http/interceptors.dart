import 'dart:developer';

import 'package:dio/dio.dart';

import '../constant/app_config.dart';
import '../util/auth_manager.dart';
import 'dio_manager.dart';

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
    DioManager.addToken(options.cancelToken ??= DioManager.defaultCancelToken);
    handler.next(options);
  }
}

class AuthInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    if (AppConfig.baseUrl.startsWith("${uri.scheme}://${uri.host}") &&
        AuthManager.isLogin) {
      options.headers['authorization'] = 'Bearer ${AuthManager.token}';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final uri = response.requestOptions.uri;
    if (AppConfig.baseUrl.startsWith("${uri.scheme}://${uri.host}") &&
        response.statusCode == 401) {
      await AuthManager.logout(response.data, true);
    } else {
      handler.next(response);
    }
  }
}
