import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/theme/lot_status_visuals.dart';
import 'package:latlong2/latlong.dart';

/// Lienzo cartesiano que representa todos los lotes locales del establecimiento.
class LotOverviewCanvas extends StatefulWidget {
  /// Crea el visor y su navegación por toque de polígono.
  const LotOverviewCanvas({
    required this.lots,
    required this.onLotSelected,
    this.photo,
    this.onSelectPhoto,
    super.key,
  });

  /// Colección activa obtenida desde SQLite.
  final List<Lot> lots;

  /// Notifica el UUID del polígono tocado.
  final ValueChanged<String> onLotSelected;

  /// Foto local dibujada detrás de los polígonos esquemáticos.
  final Uint8List? photo;

  /// Permite elegir o sustituir el fondo.
  final VoidCallback? onSelectPhoto;

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

  @override
  void dispose() {
    _hitNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.backgroundSecondary)),
          if (widget.photo case final photo?)
            Positioned.fill(
              child: Image.memory(
                photo,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          FlutterMap(
            options: MapOptions(
              crs: const CrsSimple(),
              initialCameraFit: CameraFit.bounds(
                bounds: _bounds,
                padding: const EdgeInsets.all(AppSpacing.md),
                minZoom: -8,
              ),
              minZoom: -8,
              maxZoom: 3,
              backgroundColor: Colors.transparent,
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
                        color: lot.status.color.withValues(alpha: 0.28),
                        borderColor: lot.status.color,
                        borderStrokeWidth: 3,
                        label: lot.name,
                        labelStyle: AppTypography.smallEmphasis,
                        hitValue: lot.id,
                      ),
                  ],
                ),
              ),
            ],
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
          if (widget.onSelectPhoto case final select?)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: IconButton.filledTonal(
                tooltip: FieldStrings.selectMapPhoto,
                onPressed: select,
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
            ),
        ],
      ),
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
