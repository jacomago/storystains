import 'package:dio/dio.dart';
import '../../constant/app_config.dart';

import 'interceptors.dart';

/// Class for creating a dio manager with the base url and attach interceptors
class DioManager {
  /// The instance of [Dio] to use in the app
  late final Dio dio = Dio(BaseOptions(
    receiveDataWhenStatusError: true,
    baseUrl: AppConfig.baseUrl,
  ))
    ..interceptors.addAll(interceptors);

  /// Get instance of dio manager
  DioManager();

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
