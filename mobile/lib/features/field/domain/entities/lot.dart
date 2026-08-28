import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

part 'lot.freezed.dart';

/// Lote durable perteneciente a un establecimiento.
@freezed
sealed class Lot with _$Lot {
  /// Crea un lote identificado localmente y apto para sincronización futura.
  const factory Lot({
    required String id,
    required String establishmentId,
    required String name,
    required LotBoundary boundary,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Lot;
}
