import 'package:dio/dio.dart';

import 'interceptors.dart';

class DioManager {
  late CancelToken defaultCancelToken = CancelToken();
  late final Dio dio = Dio()..interceptors.addAll(interceptors);
  late final Set<CancelToken> _cancelTokens = Set.identity();

  DioManager();

  Future<bool> setBaseUrl(String url) async {
    cancelAll();
    dio.options.baseUrl = url;
    return true;
  }

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
