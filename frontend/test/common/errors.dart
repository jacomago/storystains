import 'package:dio/dio.dart';

DioException testApiError(int code, String msg) => DioException(
    requestOptions: RequestOptions(path: ""),
    type: DioExceptionType.response,
    response: Response(
      statusCode: code,
      data: msg,
      requestOptions: RequestOptions(path: ""),
    ));
