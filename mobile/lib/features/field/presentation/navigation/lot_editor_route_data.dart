import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';

/// Contexto local necesario para crear otro lote sin superponer referencias.
class LotEditorRouteData {
  /// Crea los parametros inmutables de navegacion.
  const LotEditorRouteData({
    required this.establishmentId,
    required this.existingLots,
    this.showSatelliteMap = false,
  });

  /// Establecimiento propietario del nuevo lote.
  final String establishmentId;

  /// Snapshot de lotes visibles al abrir el editor.
  final List<Lot> existingLots;

  /// Conserva el mismo fondo visual del visor al abrir el dibujo.
  final bool showSatelliteMap;
}
