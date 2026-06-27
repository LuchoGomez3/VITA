import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';

part 'result_state.freezed.dart';

/// UI-friendly async state used by blocs and cubits.
@freezed
abstract class ResultState<T> with _$ResultState<T> {
  /// Initial state before an async operation starts.
  const factory ResultState.initial() = Initial<T>;

  /// Loading state while an async operation is running.
  const factory ResultState.loading() = Loading<T>;

  /// Completed state with loaded [data].
  const factory ResultState.data(T data) = Data<T>;

  /// Failed state with a domain [error].
  const factory ResultState.error(DomainException error) = ResultError<T>;
}
