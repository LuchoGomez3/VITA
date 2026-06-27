import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_exception.freezed.dart';

/// Stable domain error categories used by repositories and use cases.
enum DomainErrorCode {
  /// Unexpected failure without a more specific category.
  unknown,

  /// User or domain input failed validation.
  validation,

  /// The requested entity was not found.
  notFound,

  /// The current user cannot perform the operation.
  unauthorized,

  /// The operation requires connectivity or pending sync state.
  offline,

  /// The local or remote sync operation failed.
  syncFailed,
}

/// Exception used to surface domain failures with user-facing messages.
@freezed
abstract class DomainException with _$DomainException implements Exception {
  /// Creates a domain exception with a message and a stable error code.
  const factory DomainException({
    required String message,
    @Default(DomainErrorCode.unknown) DomainErrorCode code,
  }) = _DomainException;
}
