import 'package:dio/dio.dart';

import '../../data/network/api.dart';

String errorMessage(DioError error) {
  if (error.type == DioErrorType.connectTimeout) {
    return "Connection timed out";
  } else if (error.type == DioErrorType.response) {
    switch (error.response?.statusCode) {
      case 400:
        return BadRequestException(error.response!.statusMessage).toString();
      case 401:
        return UnauthorisedException(error.response!.statusMessage).toString();
      case 403:
        return ForbiddenException(error.response!.statusMessage).toString();
      case 404:
        return NotFoundException(error.response!.statusMessage).toString();
      case 500:
        return InternalErrorException(error.response!.statusMessage).toString();
      default:
        return FetchDataException(
          'Error occured while connecting to server with StatusCode : ${error.response?.statusCode}',
        ).toString();
    }
  } else {
    return "Unkown Error";
  }
}
