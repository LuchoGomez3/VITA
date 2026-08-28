import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';

/// Contexto local necesario para crear otro lote sin superponer referencias.
class LotEditorRouteData {
  /// Crea los parámetros inmutables de navegación.
  const LotEditorRouteData({
    required this.establishmentId,
    required this.existingLots,
  });

  /// Establecimiento propietario del nuevo lote.
  final String establishmentId;

  /// Snapshot de lotes visibles al abrir el editor.
  final List<Lot> existingLots;
}
