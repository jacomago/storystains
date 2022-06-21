import 'package:dio/dio.dart';

DioError testApiError(int code, String msg) => DioError(
    requestOptions: RequestOptions(path: ""),
    type: DioErrorType.response,
    response: Response(
      statusCode: code,
      data: msg,
      requestOptions: RequestOptions(path: ""),
    ));
