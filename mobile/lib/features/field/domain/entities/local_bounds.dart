import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';

part 'local_bounds.freezed.dart';

/// Extensión cartesiana usada por el lienzo lógico de lotes.
@freezed
sealed class LocalBounds with _$LocalBounds {
  /// Crea los extremos del espacio local.
  const factory LocalBounds({
    required LocalPoint minimum,
    required LocalPoint maximum,
  }) = _LocalBounds;
}
