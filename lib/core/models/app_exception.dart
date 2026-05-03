/// Base exception for all application-level errors.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Thrown when the device is offline or the server cannot be reached.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Thrown when Supabase returns an error or data fails to parse.
class DataException extends AppException {
  const DataException(super.message, [super.code]);
}

/// Thrown when an expected record (e.g. a visa by slug) is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}
