import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';

/// Representacion visual compartida de los estados de un lote.
extension LotStatusVisuals on LotStatus {
  /// Color usado por tarjetas y poligonos para identificar el estado.
  Color get color => switch (this) {
    LotStatus.active => AppColors.primary,
    LotStatus.resting => AppColors.earTagBlue,
    LotStatus.maintenance => AppColors.warning,
    LotStatus.inactive || LotStatus.unknown => AppColors.textHint,
  };
}
