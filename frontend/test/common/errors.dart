import 'package:dio/dio.dart';

DioError testApiError(int code, String msg) => DioError(
    requestOptions: RequestOptions(path: ""),
    type: DioErrorType.response,
    response: Response(
      statusCode: 400,
      data: "Cannot be empty.",
      requestOptions: RequestOptions(path: ""),
    ));
