import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:storystains/utils/utils.dart';

import '../../common/constant/app_config.dart';
import 'api.dart';

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
    Api.dioManager
        .addToken(options.cancelToken ??= Api.dioManager.defaultCancelToken);
    handler.next(options);
  }
}

class AuthInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final uri = options.uri;
    final tokenExists = await Prefs.containsKey('token');
    if (AppConfig.baseUrl.startsWith("${uri.scheme}://${uri.host}") &&
        tokenExists) {
      options.headers['authorization'] =
          'Bearer ${await Prefs.getString('token')}';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final uri = response.requestOptions.uri;
    if (AppConfig.baseUrl.startsWith("${uri.scheme}://${uri.host}") &&
        response.statusCode == 401) {
      await Auth.logout(response.data, true);
    } else {
      handler.next(response);
    }
  }
}
