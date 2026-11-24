import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/satellite_imagery.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/field_map_photo_actions.dart';
import 'package:latlong2/latlong.dart';

/// Desplazamiento del editor respecto de su encuadre inicial.
typedef FieldMapCameraOffset = ({Offset pan, double zoom, double rotation});

/// Fondo visual compartido por el mapa de lotes y el editor.
class FieldMapBackground extends StatelessWidget {
  /// Emplea la foto local si está disponible, o la vista satelital.
  const FieldMapBackground({this.photo, this.location, this.cameraOffset, super.key});

  /// Foto privada elegida en Lotes.
  final Uint8List? photo;

  /// Coordenadas del establecimiento usadas para encuadrar la imagen satelital.
  final FieldMapLocation? location;

  /// Hace que el satélite siga al editor y cargue imagen al desplazarlo.
  final FieldMapCameraOffset? cameraOffset;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final location = this.location;
    final image = photo != null
        ? _DimmedImagery(
            child: Image.memory(photo, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
          )
        : location != null
        ? _SatelliteBackground(key: ValueKey(location), location: location, cameraOffset: cameraOffset)
        : null;
    if (image == null) return const SizedBox.expand();
    return IgnorePointer(child: image);
  }
}

class _SatelliteBackground extends StatefulWidget {
  const _SatelliteBackground({required this.location, required this.cameraOffset, super.key});

  final FieldMapLocation location;
  final FieldMapCameraOffset? cameraOffset;

  @override
  State<_SatelliteBackground> createState() => _SatelliteBackgroundState();
}

class _SatelliteBackgroundState extends State<_SatelliteBackground> {
  final MapController _controller = MapController();
  late final LatLng _center = LatLng(widget.location.center.latitude, widget.location.center.longitude);
  late final List<LatLng> _boundary = [
    for (final point in widget.location.boundary) LatLng(point.latitude, point.longitude),
  ];
  late final CameraFit? _initialFit = _boundary.length < 3
      ? null
      : CameraFit.coordinates(
          coordinates: [..._boundary, _center],
          padding: const EdgeInsets.all(AppSpacing.lg),
          maxZoom: 17,
        );
  static const _initialZoom = 15.0;
  bool _ready = false;
  bool _updateScheduled = false;

  @override
  void didUpdateWidget(covariant _SatelliteBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraOffset != widget.cameraOffset) _scheduleCameraUpdate();
  }

  void _scheduleCameraUpdate() {
    if (!_ready || _updateScheduled || widget.cameraOffset == null) return;
    _updateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      final offset = widget.cameraOffset;
      if (!mounted || offset == null) return;
      final camera = _controller.camera.withRotation(0);
      final reference = _initialFit?.fit(camera) ?? camera.withPosition(center: _center, zoom: _initialZoom);
      final target = reference.unprojectAtZoom(reference.projectAtZoom(reference.center) + offset.pan);
      _controller.moveAndRotate(target, reference.zoom + offset.zoom, offset.rotation);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _initialZoom,
        initialCameraFit: _initialFit,
        maxZoom: widget.cameraOffset == null ? satelliteMaxZoom : null,
        backgroundColor: Colors.transparent,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
        onMapReady: () {
          _ready = true;
          _scheduleCameraUpdate();
        },
      ),
      children: [
        _DimmedImagery(child: satelliteTileLayer()),
        if (_initialFit != null)
          PolylineLayer(
            simplificationTolerance: 0,
            polylines: [
              Polyline(
                points: [..._boundary, _boundary.first],
                color: AppColors.error,
                pattern: StrokePattern.dashed(segments: const [7, 5]),
                strokeWidth: 2.5,
                borderColor: AppColors.onPrimary,
                borderStrokeWidth: 1,
              ),
            ],
          ),
      ],
    );
  }
}

class _DimmedImagery extends StatelessWidget {
  const _DimmedImagery({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColorFiltered(
    colorFilter: const ColorFilter.mode(Color(0x590F2119), BlendMode.srcATop),
    child: child,
  );
}
