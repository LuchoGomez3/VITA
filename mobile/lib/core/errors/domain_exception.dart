import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_exception.freezed.dart';

enum DomainErrorCode {
  unknown,
  validation,
  notFound,
  unauthorized,
  offline,
  syncFailed,
}

@freezed
abstract class DomainException with _$DomainException {
  const factory DomainException({
    required String message,
    @Default(DomainErrorCode.unknown) DomainErrorCode code,
  }) = _DomainException;
}
