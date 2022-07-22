import 'dart:io';

import 'package:dio/dio.dart';
import '../data/network/api_exception.dart';

/// Method to convert an [DioError] message to an nicer message from the
/// [ApiException] creator
String errorMessage(DioError error) {
  if (error.type == DioErrorType.connectTimeout) {
    return 'Connection timed out';
  } else if (error.type == DioErrorType.response) {
    switch (error.response?.statusCode) {
      case 400:
        return BadRequestException(error.response!.data.toString().toString())
            .toString();
      case 401:
        return UnauthorisedException(error.response!.data.toString())
            .toString();
      case 403:
        return ForbiddenException(error.response!.data.toString()).toString();
      case 404:
        return NotFoundException(error.response!.data.toString()).toString();
      case 500:
        return InternalErrorException(error.response!.data.toString())
            .toString();
      default:
        return FetchDataException(
          'Error occured while connecting to server with StatusCode : '
          '${error.response?.statusCode}',
        ).toString();
    }
  } else if (error.type == DioErrorType.other &&
      error.error.runtimeType == SocketException) {
    return (error.error as SocketException).message;
  } else {
    return 'Unknown Error';
  }
}
