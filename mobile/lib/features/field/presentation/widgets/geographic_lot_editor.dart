import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
import 'package:frontend_mayoral/core/widgets/satellite_imagery.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/field_map_photo_actions.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_lot_placement_resolver.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/theme/lot_status_visuals.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_map_background.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_map_fullscreen_button.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_vertex_marker.dart';
import 'package:latlong2/latlong.dart';

/// Viewport cartesiano para delimitar un lote sobre el fondo del establecimiento.
class GeographicLotEditor extends StatefulWidget {
  /// Crea el editor conectado con el estado de presentación.
  const GeographicLotEditor({
    required this.state,
    required this.onVertexAdded,
    required this.onVertexSelected,
    required this.onVertexMoveStarted,
    required this.onVertexMoved,
    this.existingLots = const [],
    this.photo,
    this.location,
    this.expanded = false,
    this.onToggleFullscreen,
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

  /// Foto elegida previamente en el mapa de Lotes.
  final Uint8List? photo;

  /// Coordenadas usadas para mostrar la misma vista satelital que en Lotes.
  final FieldMapLocation? location;

  /// Indica si el editor está ampliado.
  final bool expanded;

  /// Solicita cambiar entre el editor ampliado y el formulario.
  final VoidCallback? onToggleFullscreen;

  @override
  State<GeographicLotEditor> createState() => _GeographicLotEditorState();
}

class _GeographicLotEditorState extends State<GeographicLotEditor> {
  static final _canvasFit = CameraFit.bounds(
    bounds: LatLngBounds(
      const LatLng(0, 0),
      const LatLng(LocalCanvasProjection.viewportHeight, LocalCanvasProjection.viewportWidth),
    ),
    padding: const EdgeInsets.all(AppSpacing.md),
    minZoom: -8,
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
    final hasImage = widget.photo != null || widget.location != null;
    final draftOutline = hasImage ? AppColors.onPrimary : AppColors.primary;
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
              initialCameraFit: _canvasFit,
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
                final placement = _resolvePlacement(
                  LocalCanvasProjection.fromViewport(point),
                );
                if (placement.isBlocked) {
                  _showBlockedPlacementMessage();
                  return;
                }
                widget.onVertexAdded(placement.point);
              },
            ),
            children: [
              if (hasImage)
                Positioned.fill(
                  child: _EditorMapBackground(
                    fit: _canvasFit,
                    photo: widget.photo,
                    location: widget.location,
                  ),
                ),
              if (widget.existingLots.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    for (final lot in widget.existingLots)
                      Polygon(
                        points: [
                          for (final vertex in lot.boundary.vertices) LocalCanvasProjection.toViewport(vertex),
                        ],
                        color: hasImage
                            ? lot.status.color.withValues(alpha: 0.76)
                            : AppColors.textHint.withValues(alpha: 0.20),
                        borderColor: hasImage ? AppColors.onPrimary.withValues(alpha: 0.7) : AppColors.textHint,
                        borderStrokeWidth: 2,
                        label: lot.name,
                        labelStyle: hasImage
                            ? AppTypography.smallEmphasis.copyWith(color: AppColors.onPrimary)
                            : AppTypography.smallEmphasis,
                      ),
                  ],
                ),
              if (mapPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: mapPoints,
                      color: AppColors.primary.withValues(
                        alpha: hasImage ? 0.88 : (widget.state.isClosed ? 0.30 : 0.18),
                      ),
                      borderColor: draftOutline,
                      borderStrokeWidth: widget.state.isClosed ? 3 : 2,
                    ),
                  ],
                ),
              if (mapPoints.length >= 2 && !widget.state.isClosed)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapPoints,
                      color: draftOutline,
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
                        onMoved: (point) {
                          final placement = _resolvePlacement(point);
                          if (!placement.isBlocked) {
                            widget.onVertexMoved(index, placement.point);
                          }
                        },
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
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Column(
              children: [
                if (widget.onToggleFullscreen case final toggle?)
                  FieldMapFullscreenButton(expanded: widget.expanded, onPressed: toggle),
                const _NorthIndicator(),
              ],
            ),
          ),
          const Positioned(
            bottom: AppSpacing.sm,
            left: AppSpacing.sm,
            child: _LocalDraftBadge(),
          ),
          if (widget.photo == null && widget.location != null)
            const Positioned(
              bottom: AppSpacing.xs,
              right: AppSpacing.xs,
              left: 120,
              child: IgnorePointer(child: SatelliteAttribution()),
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

  LocalLotPlacement _resolvePlacement(LocalPoint point) {
    if (widget.existingLots.isEmpty) {
      return LocalLotPlacement(point: point, isBlocked: false);
    }
    final viewportPoint = LocalCanvasProjection.toViewport(point);
    final screenPoint = _mapController.camera.latLngToScreenOffset(
      viewportPoint,
    );
    final toleranceViewport = _mapController.camera.screenOffsetToLatLng(
      screenPoint + const Offset(18, 0),
    );
    final tolerancePoint = LocalCanvasProjection.fromViewport(
      toleranceViewport,
    );
    final tolerance = (tolerancePoint.x - point.x).abs();
    return LocalLotPlacementResolver.resolve(
      point: point,
      existingLots: widget.existingLots,
      snapTolerance: tolerance,
    );
  }

  void _showBlockedPlacementMessage() {
    AppToastHost.show(context, FieldStrings.vertexInsideLotError);
  }
}

class _EditorMapBackground extends StatelessWidget {
  const _EditorMapBackground({required this.fit, required this.photo, required this.location});

  final CameraFit fit;
  final Uint8List? photo;
  final FieldMapLocation? location;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    // Ancla la imagen al encuadre inicial del lienzo para que siga a los vértices.
    final reference = fit.fit(camera.withRotation(0));
    final photo = this.photo;
    if (photo == null) {
      return FieldMapBackground(
        location: location,
        cameraOffset: (
          pan: reference.projectAtZoom(camera.center) - reference.projectAtZoom(reference.center),
          zoom: camera.zoom - reference.zoom,
          rotation: camera.rotation,
        ),
      );
    }
    final offset = camera.latLngToScreenOffset(reference.center) - camera.nonRotatedSize.center(Offset.zero);
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: camera.rotationRad,
        child: Transform.scale(
          scale: camera.getZoomScale(camera.zoom, reference.zoom),
          child: FieldMapBackground(photo: photo),
        ),
      ),
    );
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
          style: AppTypography.mapBadge,
        ),
      ),
    );
  }
}
