import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';

part 'result.freezed.dart';

/// Functional result used by domain operations that can succeed or fail.
@freezed
abstract class Result<T> with _$Result<T> {
  /// Successful result containing [data].
  const factory Result.success(T data) = Success<T>;

  /// Failed result containing a domain [error].
  const factory Result.failure(DomainException error) = Failure<T>;
}
