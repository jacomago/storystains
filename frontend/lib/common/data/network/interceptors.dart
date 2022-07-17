import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../../utils/service_locator.dart';
import 'dio_manager.dart';

/// Dio interceptors of requets
List<Interceptor> interceptors(PersistCookieJar? cookieJar) => [
      CancelInterceptors(),
      if (!kIsWeb) CookieManager(cookieJar!),
      LogInterceptor(
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        logPrint: (msg) => log(msg.toString(), name: 'HTTP'),
      ),
    ];

/// Interceptor for cancelling requests
class CancelInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    ServiceLocator.sl.get<DioManager>().addToken(
          options.cancelToken ??=
              ServiceLocator.sl.get<DioManager>().defaultCancelToken,
        );
    handler.next(options);
  }
}
