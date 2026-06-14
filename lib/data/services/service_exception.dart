/// Exception wrapper for all service layer errors
class ServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  ServiceException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}
