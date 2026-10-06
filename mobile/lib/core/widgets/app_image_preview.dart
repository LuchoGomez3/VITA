import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Visor de una imagen en memoria con zoom y orientación configurable.
class AppImagePreview extends StatefulWidget {
  /// Reserva la altura indicada y permite ajustar la orientación de la imagen.
  const AppImagePreview({
    required this.bytes,
    required this.height,
    this.quarterTurns = 0,
    this.maxScale = 4,
    this.fillHeight = false,
    this.zoomEnabled = true,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
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

  /// Ajusta la imagen al alto del visor y permite desplazar los bordes laterales.
  final bool fillHeight;

  /// Habilita el pellizco y el desplazamiento dentro del visor.
  final bool zoomEnabled;

  /// Recorta las esquinas del lienzo sin alterar los bytes de la fotografía.
  final BorderRadiusGeometry borderRadius;

  /// Acción ejecutada al tocar una vista previa sin zoom.
  final VoidCallback? onTap;

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
  Widget build(BuildContext context) {
    final image = widget.fillHeight
        ? SizedBox.expand(
            // El lienzo conserva el tamaño del visor para calcular el zoom y
            // sus límites desde la misma superficie visible.
            child: RotatedBox(
              quarterTurns: widget.quarterTurns,
              child: Image.memory(
                widget.bytes,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          )
        : Center(
            child: RotatedBox(
              quarterTurns: widget.quarterTurns,
              child: Image.memory(widget.bytes, fit: BoxFit.contain, gaplessPlayback: true),
            ),
          );
    final content = widget.zoomEnabled
        ? Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _startInteraction,
            onPointerUp: _finishInteraction,
            onPointerCancel: _finishInteraction,
            child: InteractiveViewer(minScale: 1, maxScale: widget.maxScale, child: image),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: image,
          );
    return SizedBox(
      height: widget.height,
      child: ClipRRect(borderRadius: widget.borderRadius, child: content),
    );
  }
}
