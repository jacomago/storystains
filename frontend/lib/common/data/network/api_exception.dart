import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String? _message;
  final String? _prefix;

  ApiException([this._message, this._prefix]);

  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class FetchDataException extends ApiException {
  FetchDataException([message]) : super(message, 'Connection Error: ');
}

class BadRequestException extends ApiException {
  BadRequestException([message]) : super(message, 'Bad Request: ');
}

class UnauthorisedException extends ApiException {
  UnauthorisedException([message]) : super(message, 'Unauthorised: ');
}

class ForbiddenException extends ApiException {
  ForbiddenException([message]) : super(message, 'Forbidden: ');
}

class NotFoundException extends ApiException {
  NotFoundException([message]) : super(message, 'Forbidden: ');
}

class InternalErrorException extends ApiException {
  InternalErrorException([message]) : super(message, 'Internal server error: ');
}

class StatusCodeException {
  static ApiException exception(Response response) {
    switch (response.statusCode) {
      case 401:
        {
          return UnauthorisedException(response.statusMessage);
        }
      case 400:
        {
          return BadRequestException(response.statusMessage);
        }
      case 500:
        {
          return InternalErrorException(response.statusMessage);
        }
    }
    return FetchDataException(response.statusMessage);
  }
}
