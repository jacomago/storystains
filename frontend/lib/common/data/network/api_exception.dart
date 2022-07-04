class ApiException implements Exception {
  final String? _message;
  final String? _prefix;

  ApiException([this._message, this._prefix]);

  @override
  String toString() => '$_prefix$_message';
}

class FetchDataException extends ApiException {
  FetchDataException([String? message]) : super(message, 'Connection Error: ');
}

class BadRequestException extends ApiException {
  BadRequestException([String? message]) : super(message, 'Bad Request: ');
}

class UnauthorisedException extends ApiException {
  UnauthorisedException([String? message]) : super(message, 'Unauthorised: ');
}

class ForbiddenException extends ApiException {
  ForbiddenException([String? message]) : super(message, 'Forbidden: ');
}

class NotFoundException extends ApiException {
  NotFoundException([String? message]) : super(message, 'Not Found: ');
}

class InternalErrorException extends ApiException {
  InternalErrorException([String? message])
      : super(message, 'Internal server error: ');
}
