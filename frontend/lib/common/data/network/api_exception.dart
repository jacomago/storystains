/// Representaion of a generic exception from the api
class ApiException implements Exception {
  final String? _message;
  final String? _prefix;

  /// Constructor of Exception
  ApiException([this._message, this._prefix]);

  @override
  String toString() => '$_prefix$_message';
}

/// No connection exception
class FetchDataException extends ApiException {
  /// Constructor for No connection exception
  FetchDataException([String? message]) : super(message, 'Connection Error: ');
}

/// Bad request exception
class BadRequestException extends ApiException {
  /// Constructor for Bad request exception
  BadRequestException([String? message]) : super(message, 'Bad Request: ');
}

/// Unauthorised exception for 401s
class UnauthorisedException extends ApiException {
  /// Constructor for unauthorised exception
  UnauthorisedException([String? message]) : super(message, 'Unauthorised: ');
}

/// Forbidden exception for 403s
class ForbiddenException extends ApiException {
  /// Forbidden exceptoin for 403s
  ForbiddenException([String? message]) : super(message, 'Forbidden: ');
}

/// Not found exception for 404s
class NotFoundException extends ApiException {
  /// Not found exception for 404s
  NotFoundException([String? message]) : super(message, 'Not Found: ');
}

/// Internal server error exception for 500s
class InternalErrorException extends ApiException {
  /// Internal server error exception for 500s
  InternalErrorException([String? message])
      : super(message, 'Internal server error: ');
}
