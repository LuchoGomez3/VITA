import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_draft_validation.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/location_failure_message.dart';
import 'package:latlong2/latlong.dart';

/// Paso 4 · Delimitar la superficie del establecimiento.
///
/// El productor marca los vértices tocando el mapa o, recorriendo el campo,
/// con el GPS. La imagen satelital es una ayuda: sin conexión el mapa queda
/// con fondo neutro y todo lo demás funciona igual. Si no puede dibujar el
/// campo, carga la superficie a mano. Ver ADR-0009.
class EstablishmentRegisterSurfaceStep extends StatelessWidget {
  /// Crea el paso de delimitación de superficie del establecimiento.
  const EstablishmentRegisterSurfaceStep({
    super.key,
    this.showSatelliteImagery = true,
  });

  /// Si se piden tiles satelitales. Los tests lo apagan para no usar la red.
  final bool showSatelliteImagery;

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.draft,
    );
    final canUndo = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.boundaryHistory.isNotEmpty,
    );
    final isReadingGps = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.boundaryGpsResult is Loading<CurrentLocation>,
    );

    return BlocListener<RegisterEstablishmentBloc, RegisterEstablishmentState>(
      listenWhen: (previous, current) => previous.boundaryGpsResult != current.boundaryGpsResult,
      listener: (context, state) {
        final message = switch (state.boundaryGpsResult) {
          ResultError<CurrentLocation>(:final error) => locationFailureMessage(error),
          Data<CurrentLocation>(:final data) => EstablishmentRegisterStrings.stepFourGpsVertexAdded(
            data.precisionMetros.round(),
          ),
          _ => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.backgroundSecondary,
            child: const Row(
              children: [
                Icon(Icons.layers_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    EstablishmentRegisterStrings.stepFourBannerText,
                    style: AppTypography.smallEmphasis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _BoundaryEditor(
              draft: draft,
              canUndo: canUndo,
              isReadingGps: isReadingGps,
              showSatelliteImagery: showSatelliteImagery,
            ),
          ),
          if (draft.poligono.isEmpty) _ManualSurfacePanel(superficie: draft.superficieManualHectareas),
        ],
      ),
    );
  }
}

class _BoundaryEditor extends StatefulWidget {
  const _BoundaryEditor({
    required this.draft,
    required this.canUndo,
    required this.isReadingGps,
    required this.showSatelliteImagery,
  });

  final RegisterEstablishmentDraft draft;
  final bool canUndo;
  final bool isReadingGps;
  final bool showSatelliteImagery;

  @override
  State<_BoundaryEditor> createState() => _BoundaryEditorState();
}

class _BoundaryEditorState extends State<_BoundaryEditor> {
  /// Imagen satelital de Esri (World Imagery). Ver ADR-0009 por términos de uso.
  static const _satelliteUrlTemplate =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  /// Centro de Córdoba, para cuando todavía no hay lectura del GPS.
  static const _fallbackCenter = LatLng(-31.4201, -64.1888);

  final MapController _mapController = MapController();
  late bool _isSatelliteOn = widget.showSatelliteImagery;
  bool _isSatelliteUnavailable = false;
  bool _isDraggingVertex = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final reference = draft.ubicacionConfirmadaPorGps ? LatLng(draft.latitud, draft.longitud) : null;
    final mapPoints = [for (final point in draft.poligono) LatLng(point.latitud, point.longitud)];
    final issue = draft.surfaceStepIssue;
    final isClosed = draft.poligono.length >= 3;

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          // Si el paso 3 vuelve a leer el GPS, el mapa se recentra ahí.
          key: ValueKey(reference),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: reference ?? _fallbackCenter,
            initialZoom: reference == null ? 7 : 15,
            maxZoom: 19,
            backgroundColor: AppColors.backgroundSecondary,
            interactionOptions: InteractionOptions(
              flags: _isDraggingVertex ? InteractiveFlag.none : InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (_, point) => _bloc.add(
              RegisterEstablishmentEvent.boundaryPointAdded(
                BoundaryPoint(latitud: point.latitude, longitud: point.longitude),
              ),
            ),
          ),
          children: [
            if (_isSatelliteOn)
              TileLayer(
                urlTemplate: _satelliteUrlTemplate,
                userAgentPackageName: 'com.example.frontend_mayoral',
                errorTileCallback: (_, _, _) => _markSatelliteUnavailable(),
              ),
            if (isClosed)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: mapPoints,
                    color: (issue == null ? AppColors.primary : AppColors.error).withValues(alpha: 0.25),
                    borderColor: issue == null ? AppColors.primary : AppColors.error,
                    borderStrokeWidth: 3,
                  ),
                ],
              )
            else if (mapPoints.length == 2)
              PolylineLayer(
                polylines: [Polyline(points: mapPoints, color: AppColors.primary, strokeWidth: 3)],
              ),
            MarkerLayer(
              markers: [
                if (reference != null)
                  Marker(
                    point: reference,
                    width: 32,
                    height: 32,
                    alignment: Alignment.topCenter,
                    child: const IgnorePointer(
                      child: Icon(Icons.location_on, size: 32, color: AppColors.error),
                    ),
                  ),
                for (var index = 0; index < mapPoints.length; index++)
                  Marker(
                    point: mapPoints[index],
                    width: 48,
                    height: 48,
                    child: _BoundaryVertexMarker(
                      index: index,
                      point: mapPoints[index],
                      mapController: _mapController,
                      onDragStarted: () {
                        setState(() => _isDraggingVertex = true);
                        _bloc.add(const RegisterEstablishmentEvent.boundaryPointMoveStarted());
                      },
                      onDragEnded: () => setState(() => _isDraggingVertex = false),
                      onMoved: (point) => _bloc.add(
                        RegisterEstablishmentEvent.boundaryPointMoved(
                          index,
                          BoundaryPoint(latitud: point.latitude, longitud: point.longitude),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_isSatelliteOn && !_isSatelliteUnavailable)
              const SimpleAttributionWidget(
                source: Text(EstablishmentRegisterStrings.stepFourSatelliteAttribution),
              ),
          ],
        ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          right: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SurfaceStatsChip(
                superficieHectareas: draft.superficieHectareas,
                cantidadVertices: draft.poligono.length,
              ),
              if (_isSatelliteOn && _isSatelliteUnavailable) ...[
                const SizedBox(height: AppSpacing.xs),
                const _SatelliteUnavailableNotice(),
              ],
            ],
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Column(
            children: [
              _ToolButton(
                icon: Icons.my_location,
                tooltip: EstablishmentRegisterStrings.stepFourGpsVertexTooltip,
                isLoading: widget.isReadingGps,
                onPressed: () => _bloc.add(const RegisterEstablishmentEvent.boundaryPointFromGpsRequested()),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToolButton(
                icon: Icons.undo,
                tooltip: EstablishmentRegisterStrings.stepFourUndoTooltip,
                onPressed: widget.canUndo
                    ? () => _bloc.add(const RegisterEstablishmentEvent.boundaryUndoRequested())
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToolButton(
                icon: Icons.close,
                tooltip: EstablishmentRegisterStrings.stepFourClearTooltip,
                onPressed: draft.poligono.isNotEmpty
                    ? () => _bloc.add(const RegisterEstablishmentEvent.boundaryCleared())
                    : null,
              ),
              if (widget.showSatelliteImagery) ...[
                const SizedBox(height: AppSpacing.xs),
                _ToolButton(
                  icon: _isSatelliteOn ? Icons.satellite_alt : Icons.layers_outlined,
                  tooltip: EstablishmentRegisterStrings.stepFourLayerTooltip,
                  onPressed: () => setState(() {
                    _isSatelliteOn = !_isSatelliteOn;
                    _isSatelliteUnavailable = false;
                  }),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: AppSpacing.lg,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: _HintPill(text: _hintFor(draft)),
        ),
      ],
    );
  }

  RegisterEstablishmentBloc get _bloc => context.read<RegisterEstablishmentBloc>();

  /// Los tiles fallan de a muchos y fuera del build: avisa una sola vez.
  void _markSatelliteUnavailable() {
    if (!mounted || _isSatelliteUnavailable) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isSatelliteUnavailable = true);
      }
    });
  }

  static String _hintFor(RegisterEstablishmentDraft draft) {
    if (draft.poligono.isEmpty) {
      return EstablishmentRegisterStrings.stepFourHintEmpty;
    }
    return switch (draft.surfaceStepIssue) {
      SurfaceStepIssue.tooFewVertices => EstablishmentRegisterStrings.stepFourHintTooFewVertices,
      SurfaceStepIssue.selfIntersecting => EstablishmentRegisterStrings.stepFourHintSelfIntersecting,
      SurfaceStepIssue.missingSurface || null => EstablishmentRegisterStrings.stepFourHintText,
    };
  }
}

/// Vértice numerado y arrastrable sobre el mapa geográfico.
///
/// Misma mecánica que `LotVertexMarker` (lotes), pero sobre coordenadas
/// reales en lugar del lienzo esquemático.
class _BoundaryVertexMarker extends StatefulWidget {
  const _BoundaryVertexMarker({
    required this.index,
    required this.point,
    required this.mapController,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onMoved,
  });

  final int index;
  final LatLng point;
  final MapController mapController;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<LatLng> onMoved;

  @override
  State<_BoundaryVertexMarker> createState() => _BoundaryVertexMarkerState();
}

class _BoundaryVertexMarkerState extends State<_BoundaryVertexMarker> {
  Offset? _dragScreenOffset;

  @override
  Widget build(BuildContext context) {
    final isDragging = _dragScreenOffset != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Tocar un vértice no agrega otro encima.
      onTap: () {},
      onPanStart: (_) {
        setState(() {
          _dragScreenOffset = widget.mapController.camera.latLngToScreenOffset(widget.point);
        });
        widget.onDragStarted();
      },
      onPanUpdate: (details) {
        final dragScreenOffset = _dragScreenOffset;
        if (dragScreenOffset == null) {
          return;
        }
        final nextScreenOffset = dragScreenOffset + details.delta;
        _dragScreenOffset = nextScreenOffset;
        widget.onMoved(widget.mapController.camera.screenOffsetToLatLng(nextScreenOffset));
      },
      onPanEnd: (_) => _endDrag(),
      onPanCancel: _endDrag,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: isDragging ? 34 : 28,
          height: isDragging ? 34 : 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDragging ? AppColors.textPrimary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)],
          ),
          child: Text(
            '${widget.index + 1}',
            style: AppTypography.smallEmphasis.copyWith(
              color: isDragging ? AppColors.onPrimary : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _endDrag() {
    if (_dragScreenOffset == null) {
      return;
    }
    setState(() => _dragScreenOffset = null);
    widget.onDragEnded();
  }
}

class _ManualSurfacePanel extends StatefulWidget {
  const _ManualSurfacePanel({required this.superficie});

  final double? superficie;

  @override
  State<_ManualSurfacePanel> createState() => _ManualSurfacePanelState();
}

class _ManualSurfacePanelState extends State<_ManualSurfacePanel> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.superficie == null ? '' : _format(widget.superficie!),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
        child: AppTextFormField(
          controller: _controller,
          title: EstablishmentRegisterStrings.stepFourManualSurfaceTitle,
          hintText: EstablishmentRegisterStrings.stepFourManualSurfaceFieldTitle,
          helperText: EstablishmentRegisterStrings.stepFourManualSurfaceHelper,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,6}([.,]\d{0,2})?'))],
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            final bloc = context.read<RegisterEstablishmentBloc>();
            bloc.add(
              RegisterEstablishmentEvent.draftChanged(
                bloc.state.draft.copyWith(
                  superficieManualHectareas: double.tryParse(value.replaceAll(',', '.')),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _format(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

class _SurfaceStatsChip extends StatelessWidget {
  const _SurfaceStatsChip({
    required this.superficieHectareas,
    required this.cantidadVertices,
  });

  final double superficieHectareas;
  final int cantidadVertices;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SurfaceStat(
            label: EstablishmentRegisterStrings.stepFourSurfaceLabel,
            value: cantidadVertices >= 3 ? EstablishmentRegisterStrings.hectares(superficieHectareas) : '—',
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: AppSpacing.sm),
          _SurfaceStat(
            label: EstablishmentRegisterStrings.stepFourVerticesLabel,
            value: '$cantidadVertices',
          ),
        ],
      ),
    );
  }
}

class _SurfaceStat extends StatelessWidget {
  const _SurfaceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.formFieldHelper),
        Text(value, style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary)),
      ],
    );
  }
}

class _SatelliteUnavailableNotice extends StatelessWidget {
  const _SatelliteUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 16, color: AppColors.textSecondary),
          SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              EstablishmentRegisterStrings.stepFourSatelliteUnavailable,
              style: AppTypography.formFieldHelper,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.onPrimary,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onPressed : null,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: isEnabled ? AppColors.textPrimary : AppColors.textHint,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
