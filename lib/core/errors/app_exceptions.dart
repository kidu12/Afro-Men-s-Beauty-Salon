class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class BookingException extends AppException {
  BookingException(super.message, {super.code, super.details});
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

class ForbiddenException extends AppException {
  ForbiddenException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  NetworkException([super.message = "Unable to connect to Afro Men's Beauty Salon server. Please check your XAMPP connection."]);
}

class ServerException extends AppException {
  ServerException([super.message = 'An unexpected server error occurred. Please try again.']);
}
