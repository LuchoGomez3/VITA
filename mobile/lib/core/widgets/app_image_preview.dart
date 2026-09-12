import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Visor de una imagen en memoria con zoom, sin recortar ni deformar su contenido.
class AppImagePreview extends StatefulWidget {
  /// Reserva la altura indicada y permite ajustar la orientación de la imagen.
  const AppImagePreview({
    required this.bytes,
    required this.height,
    this.quarterTurns = 0,
    this.maxScale = 4,
    this.onInteractionChanged,
    super.key,
  });

  /// Archivo codificado que Flutter decodifica para mostrar la imagen.
  final Uint8List bytes;

  /// Altura del visor; cada pantalla decide cuánto espacio reservar.
  final double height;

  /// Giros de 90 grados aplicados antes de mostrar la imagen.
  final int quarterTurns;

  /// Ampliación máxima disponible para inspeccionar detalles.
  final double maxScale;

  /// Permite suspender el scroll del contenedor mientras se toca el visor.
  /// Se informa desde el primer dedo, antes de que el scroll gane el gesto.
  final ValueChanged<bool>? onInteractionChanged;

  @override
  State<AppImagePreview> createState() => _AppImagePreviewState();
}

class _AppImagePreviewState extends State<AppImagePreview> {
  final Set<int> _activePointers = {};

  void _startInteraction(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    if (_activePointers.length == 1) widget.onInteractionChanged?.call(true);
  }

  void _finishInteraction(PointerEvent event) {
    if (_activePointers.remove(event.pointer) && _activePointers.isEmpty) {
      widget.onInteractionChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.height,
    child: Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _startInteraction,
      onPointerUp: _finishInteraction,
      onPointerCancel: _finishInteraction,
      child: ClipRect(
        child: InteractiveViewer(
          maxScale: widget.maxScale,
          child: Center(
            child: RotatedBox(
              quarterTurns: widget.quarterTurns,
              child: Image.memory(widget.bytes, fit: BoxFit.contain, gaplessPlayback: true),
            ),
          ),
        ),
      ),
    ),
  );
}
