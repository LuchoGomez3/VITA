import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';

/// Pin numerado y arrastrable que representa un vértice del lote.
class LotVertexMarker extends StatefulWidget {
  /// Crea un pin conectado con el viewport geográfico actual.
  const LotVertexMarker({
    required this.index,
    required this.point,
    required this.mapController,
    required this.isSelected,
    required this.onSelected,
    required this.onInteractionStarted,
    required this.onInteractionEnded,
    required this.onMoveStarted,
    required this.onMoved,
    super.key,
  });

  /// Posición del pin dentro del perímetro.
  final int index;

  /// Coordenada geográfica actual.
  final LocalPoint point;

  /// Cámara usada para transformar el desplazamiento del gesto.
  final MapController mapController;

  /// Indica si el usuario tiene este pin seleccionado.
  final bool isSelected;

  /// Selecciona el pin.
  final VoidCallback onSelected;

  /// Bloquea temporalmente los gestos de la cámara.
  final VoidCallback onInteractionStarted;

  /// Vuelve a habilitar los gestos de la cámara.
  final VoidCallback onInteractionEnded;

  /// Crea un checkpoint antes del arrastre.
  final VoidCallback onMoveStarted;

  /// Publica la coordenada actualizada durante el arrastre.
  final ValueChanged<LocalPoint> onMoved;

  @override
  State<LotVertexMarker> createState() => _LotVertexMarkerState();
}

class _LotVertexMarkerState extends State<LotVertexMarker> {
  Offset? _dragScreenOffset;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => widget.onInteractionStarted(),
      onPointerUp: (_) => _endInteraction(),
      onPointerCancel: (_) => _endInteraction(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelected,
        onPanStart: (_) {
          widget.onSelected();
          widget.onMoveStarted();
          _dragScreenOffset = widget.mapController.camera.latLngToScreenOffset(
            LocalCanvasProjection.toViewport(widget.point),
          );
        },
        onPanUpdate: (details) {
          final dragScreenOffset = _dragScreenOffset;
          if (dragScreenOffset == null) {
            return;
          }
          final nextScreenOffset = dragScreenOffset + details.delta;
          _dragScreenOffset = nextScreenOffset;
          final movedCoordinate = widget.mapController.camera.screenOffsetToLatLng(
            nextScreenOffset,
          );
          widget.onMoved(LocalCanvasProjection.fromViewport(movedCoordinate));
        },
        onPanEnd: (_) => _dragScreenOffset = null,
        onPanCancel: () => _dragScreenOffset = null,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.isSelected ? 34 : 30,
            height: widget.isSelected ? 34 : 30,
            decoration: BoxDecoration(
              color: widget.isSelected ? AppColors.textPrimary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: const [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 6),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.index + 1}',
              style: AppTypography.smallEmphasis.copyWith(
                color: widget.isSelected ? AppColors.onPrimary : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _endInteraction() {
    _dragScreenOffset = null;
    widget.onInteractionEnded();
  }
}
