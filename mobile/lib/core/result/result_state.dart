import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result_state.freezed.dart';

@freezed
abstract class ResultState<T> with _$ResultState<T> {
  const factory ResultState.initial() = Initial<T>;
  const factory ResultState.loading() = Loading<T>;
  const factory ResultState.data(T data) = Data<T>;
  const factory ResultState.error(DomainException error) = ResultError<T>;
}
