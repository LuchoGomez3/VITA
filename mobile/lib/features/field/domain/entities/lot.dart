import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';

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
    required int surfaceTenths,
    required bool hasWater,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(LotStatus.active) LotStatus status,
    @Default(LotSyncStatus.pending) LotSyncStatus syncStatus,
    String? forageResourceCode,
    String? syncErrorCode,
    DateTime? deletedAt,
  }) = _Lot;

  const Lot._();

  /// Superficie declarada expresada en hectáreas con un decimal.
  double get surfaceHectares => surfaceTenths / 10;
}

/// Estado de sincronización visible para la gestión del lote.
enum LotSyncStatus {
  /// El cambio está guardado localmente y pendiente de backend.
  pending,

  /// Backend confirmó la versión local.
  synchronized,

  /// Backend rechazó el cambio y requiere corrección del usuario.
  rejected,
}
