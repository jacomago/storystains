import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../features/auth/auth.dart';
import '../../constant/app_config.dart';
import '../../utils/service_locator.dart';
import 'dio_manager.dart';

/// Dio interceptors of requets
final interceptors = [
  CancelInterceptors(),
  AuthInterceptors(),
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

/// Interceptor for passing in authorization token
/// And removing when receiving a 401
/// Using the [AuthState] from the [ServiceLocator]
class AuthInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final uri = options.uri;
    final authState = ServiceLocator.sl.get<AuthState>();
    await authState.init();
    if (AppConfig.baseUrl.startsWith('${uri.scheme}://${uri.host}') &&
        authState.isAuthenticated) {
      options.headers['authorization'] = 'Bearer ${authState.token}';
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final uri = response.requestOptions.uri;
    if (AppConfig.baseUrl.startsWith('${uri.scheme}://${uri.host}') &&
        response.statusCode == 401) {
      await ServiceLocator.sl.get<AuthState>().logout();
    } else {
      handler.next(response);
    }
  }
}
