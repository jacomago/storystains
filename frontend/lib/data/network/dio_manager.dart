import 'package:dio/dio.dart';
import 'package:storystains/common/constant/app_config.dart';

import 'interceptors.dart';

class DioManager {
  late CancelToken defaultCancelToken = CancelToken();
  late final Dio dio = Dio(BaseOptions(
      connectTimeout: 2000,
      receiveTimeout: 2000,
      receiveDataWhenStatusError: true, baseUrl: AppConfig.baseUrl))
    ..interceptors.addAll(interceptors);
  late final Set<CancelToken> _cancelTokens = Set.identity();

  DioManager();

  void addToken(CancelToken token) {
    _cancelTokens.add(token);
  }

  cancelAll([dynamic reason]) {
    for (var token in _cancelTokens) {
      token.cancel(reason);
    }
    _cancelTokens.clear();
    defaultCancelToken = CancelToken();
  }
}
