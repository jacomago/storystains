import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import '../../constant/app_config.dart';

import 'interceptors.dart';

/// Class for creating a dio manager with the base url and attach interceptors
class DioManager {
  /// cookie jar for Dio
  final PersistCookieJar? cookieJar;

  /// The instance of [Dio] to use in the app
  late final Dio dio = Dio(BaseOptions(
    receiveDataWhenStatusError: true,
    baseUrl: AppConfig.baseUrl,
  ))
    ..interceptors.addAll(interceptors(cookieJar));

  /// Get instance of dio manager
  DioManager([this.cookieJar]);

  /// Default token for cancelling requersts
  late CancelToken defaultCancelToken = CancelToken();

  /// Set of tokens of requests to cancel
  late final Set<CancelToken> _cancelTokens = Set.identity();

  /// Add a new cancel token
  void addToken(CancelToken token) {
    _cancelTokens.add(token);
  }

  /// Cancel all requests.
  void cancelAll([dynamic reason]) {
    for (var token in _cancelTokens) {
      token.cancel(reason);
    }
    _cancelTokens.clear();
    defaultCancelToken = CancelToken();
  }
}
