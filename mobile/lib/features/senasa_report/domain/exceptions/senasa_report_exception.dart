import 'package:frontend_mayoral/core/errors/domain_exception.dart';

/// Error raised by the SENASA report integration.
class SenasaReportException implements Exception {
  /// Creates an integration error.
  const SenasaReportException({
    required this.message,
    this.code = DomainErrorCode.unknown,
  });

  /// User-facing error message.
  final String message;

  /// Stable domain error category.
  final DomainErrorCode code;
}
