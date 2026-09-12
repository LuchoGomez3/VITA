import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_point.freezed.dart';

/// Coordenada estable dentro del lienzo lógico de un establecimiento.
@freezed
sealed class LocalPoint with _$LocalPoint {
  /// Crea un punto cartesiano sin significado GPS ni unidad física.
  const factory LocalPoint({
    required double x,
    required double y,
  }) = _LocalPoint;
}
