import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_vertex_marker.dart';
import 'package:latlong2/latlong.dart';

/// Viewport geográfico sin tiles para delimitar un lote sobre fondo neutro.
class GeographicLotEditor extends StatefulWidget {
  /// Crea el editor conectado con el estado de presentación.
  const GeographicLotEditor({
    required this.state,
    required this.onVertexAdded,
    required this.onVertexSelected,
    required this.onVertexMoveStarted,
    required this.onVertexMoved,
    this.existingLots = const [],
    super.key,
  });

  /// Estado geométrico actual.
  final LotEditorState state;

  /// Agrega un punto desde un toque en el fondo.
  final ValueChanged<LocalPoint> onVertexAdded;

  /// Selecciona el vértice de un índice.
  final ValueChanged<int> onVertexSelected;

  /// Inicia el arrastre del vértice de un índice.
  final ValueChanged<int> onVertexMoveStarted;

  /// Actualiza un vértice durante el arrastre.
  final void Function(int index, LocalPoint point) onVertexMoved;

  /// Lotes locales mostrados como referencia no editable.
  final List<Lot> existingLots;

  @override
  State<GeographicLotEditor> createState() => _GeographicLotEditorState();
}

class _GeographicLotEditorState extends State<GeographicLotEditor> {
  static final _canvasBounds = LatLngBounds(
    const LatLng(0, 0),
    const LatLng(
      LocalCanvasProjection.viewportHeight,
      LocalCanvasProjection.viewportWidth,
    ),
  );
  final MapController _mapController = MapController();
  bool _isInteractingWithVertex = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vertices = widget.state.vertices;
    final mapPoints = [
      for (final vertex in vertices) LocalCanvasProjection.toViewport(vertex),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              crs: const CrsSimple(),
              initialCameraFit: CameraFit.bounds(
                bounds: _canvasBounds,
                padding: const EdgeInsets.all(AppSpacing.md),
                minZoom: -8,
              ),
              minZoom: -8,
              maxZoom: 3,
              backgroundColor: AppColors.backgroundSecondary,
              interactionOptions: InteractionOptions(
                flags: _isInteractingWithVertex ? InteractiveFlag.none : InteractiveFlag.all,
              ),
              onTap: (_, point) {
                if (widget.state.isClosed) {
                  return;
                }
                widget.onVertexAdded(LocalCanvasProjection.fromViewport(point));
              },
            ),
            children: [
              if (widget.existingLots.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    for (final lot in widget.existingLots)
                      Polygon(
                        points: [
                          for (final vertex in lot.boundary.vertices) LocalCanvasProjection.toViewport(vertex),
                        ],
                        color: AppColors.textHint.withValues(alpha: 0.20),
                        borderColor: AppColors.textHint,
                        borderStrokeWidth: 2,
                        label: lot.name,
                        labelStyle: AppTypography.smallEmphasis,
                      ),
                  ],
                ),
              if (mapPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: mapPoints,
                      color: AppColors.primary.withValues(
                        alpha: widget.state.isClosed ? 0.30 : 0.18,
                      ),
                      borderColor: AppColors.primary,
                      borderStrokeWidth: widget.state.isClosed ? 3 : 2,
                    ),
                  ],
                ),
              if (mapPoints.length >= 2 && !widget.state.isClosed)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapPoints,
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (var index = 0; index < vertices.length; index++)
                    Marker(
                      point: mapPoints[index],
                      width: 48,
                      height: 48,
                      child: LotVertexMarker(
                        index: index,
                        point: vertices[index],
                        mapController: _mapController,
                        isSelected: widget.state.selectedVertexIndex == index,
                        onSelected: () => widget.onVertexSelected(index),
                        onInteractionStarted: _lockMapGestures,
                        onInteractionEnded: _unlockMapGestures,
                        onMoveStarted: () => widget.onVertexMoveStarted(index),
                        onMoved: (point) => widget.onVertexMoved(index, point),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            right: 52,
            child: _EditorHint(state: widget.state),
          ),
          const Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _NorthIndicator(),
          ),
          const Positioned(
            bottom: AppSpacing.sm,
            left: AppSpacing.sm,
            child: _LocalDraftBadge(),
          ),
        ],
      ),
    );
  }

  void _lockMapGestures() {
    if (!_isInteractingWithVertex) {
      setState(() => _isInteractingWithVertex = true);
    }
  }

  void _unlockMapGestures() {
    if (_isInteractingWithVertex && mounted) {
      setState(() => _isInteractingWithVertex = false);
    }
  }
}

class _EditorHint extends StatelessWidget {
  const _EditorHint({required this.state});

  final LotEditorState state;

  @override
  Widget build(BuildContext context) {
    final text = state.isClosed
        ? FieldStrings.lotEditorClosedHint
        : state.vertices.isEmpty
        ? FieldStrings.lotEditorEmptyHint
        : FieldStrings.lotEditorDrawingHint;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(text, style: AppTypography.smallEmphasis),
      ),
    );
  }
}

class _NorthIndicator extends StatelessWidget {
  const _NorthIndicator();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 36,
        child: Center(
          child: Text(
            FieldStrings.northIndicator,
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalDraftBadge extends StatelessWidget {
  const _LocalDraftBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          FieldStrings.localDraftBadge,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
