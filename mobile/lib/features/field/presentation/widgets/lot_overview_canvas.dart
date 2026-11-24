import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/satellite_imagery.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/field_map_photo_actions.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/theme/lot_status_visuals.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_map_background.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_map_fullscreen_button.dart';
import 'package:latlong2/latlong.dart';

/// Lienzo cartesiano que representa todos los lotes locales del establecimiento.
class LotOverviewCanvas extends StatefulWidget {
  /// Crea el visor y su navegación por toque de polígono.
  const LotOverviewCanvas({
    required this.lots,
    required this.onLotSelected,
    this.photo,
    this.location,
    this.onSelectPhoto,
    this.expanded = false,
    this.onToggleFullscreen,
    super.key,
  });

  /// Colección activa obtenida desde SQLite.
  final List<Lot> lots;

  /// Notifica el UUID del polígono tocado.
  final ValueChanged<String> onLotSelected;

  /// Foto local dibujada detrás de los polígonos esquemáticos.
  final Uint8List? photo;

  /// Ubicación para mostrar la imagen satelital detrás del esquema.
  final FieldMapLocation? location;

  /// Permite elegir o sustituir el fondo.
  final VoidCallback? onSelectPhoto;

  /// Muestra el control para regresar cuando el mapa ya está ampliado.
  final bool expanded;

  /// Solicita ampliar o contraer el mapa.
  final VoidCallback? onToggleFullscreen;

  @override
  State<LotOverviewCanvas> createState() => _LotOverviewCanvasState();
}

class _LotOverviewCanvasState extends State<LotOverviewCanvas> {
  static final _bounds = LatLngBounds(
    const LatLng(0, 0),
    const LatLng(
      LocalCanvasProjection.viewportHeight,
      LocalCanvasProjection.viewportWidth,
    ),
  );
  final LayerHitNotifier<String> _hitNotifier = ValueNotifier(null);
  bool _zoomed = false;

  @override
  void dispose() {
    _hitNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final location = widget.location;
    final hasImage = photo != null || location != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedScale(
              scale: _zoomed ? 1.5 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.backgroundSecondary),
                  FieldMapBackground(photo: photo, location: location),
                  _buildLotLayer(hasImage: hasImage),
                ],
              ),
            ),
          ),
          if (photo == null && location != null)
            const Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.xs,
              right: 56,
              child: IgnorePointer(child: SatelliteAttribution()),
            ),
          if (widget.lots.isEmpty)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(FieldStrings.noLocalLotsMessage),
                ),
              ),
            ),
          const Positioned(
            bottom: AppSpacing.sm,
            left: AppSpacing.sm,
            child: _LocalOnlyBadge(),
          ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: Column(
              children: [
                if (widget.onToggleFullscreen case final toggle?)
                  FieldMapFullscreenButton(expanded: widget.expanded, onPressed: toggle),
                if (widget.onSelectPhoto case final select?)
                  IconButton.filledTonal(
                    tooltip: FieldStrings.selectMapPhoto,
                    onPressed: select,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                IconButton.filledTonal(
                  tooltip: _zoomed ? FieldStrings.zoomOutMap : FieldStrings.zoomInMap,
                  onPressed: () => setState(() => _zoomed = !_zoomed),
                  icon: Icon(_zoomed ? Icons.zoom_out_rounded : Icons.zoom_in_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotLayer({required bool hasImage}) {
    return FlutterMap(
      options: MapOptions(
        crs: const CrsSimple(),
        initialCameraFit: CameraFit.bounds(
          bounds: _bounds,
          padding: const EdgeInsets.all(AppSpacing.md),
          minZoom: -8,
        ),
        minZoom: -8,
        backgroundColor: Colors.transparent,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        GestureDetector(
          onTap: () {
            final values = _hitNotifier.value?.hitValues;
            if (values != null && values.isNotEmpty) {
              widget.onLotSelected(values.first);
            }
          },
          child: PolygonLayer<String>(
            hitNotifier: _hitNotifier,
            simplificationTolerance: 0,
            polygons: [
              for (final lot in widget.lots)
                Polygon<String>(
                  points: [
                    for (final vertex in lot.boundary.vertices) LocalCanvasProjection.toViewport(vertex),
                  ],
                  color: lot.status.color.withValues(alpha: hasImage ? 0.76 : 0.32),
                  borderColor: hasImage ? AppColors.onPrimary : lot.status.color,
                  borderStrokeWidth: 2.5,
                  label: lot.name,
                  labelStyle: hasImage
                      ? AppTypography.smallEmphasis.copyWith(
                          color: AppColors.onPrimary,
                          shadows: const [Shadow(color: AppColors.textPrimary, blurRadius: 5)],
                        )
                      : AppTypography.smallEmphasis,
                  hitValue: lot.id,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocalOnlyBadge extends StatelessWidget {
  const _LocalOnlyBadge();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.textPrimary.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        FieldStrings.savedOnDeviceBadge,
        style: AppTypography.mapBadge,
      ),
    ),
  );
}
