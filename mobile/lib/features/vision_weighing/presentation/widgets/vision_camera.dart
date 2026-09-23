import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/app_navigation_dimensions.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Adaptador visual de cámara que consume casos de uso y delega el análisis.
class VisionCamera extends StatefulWidget {
  /// Crea una cámara sin audio y entrega los bytes de cada toma.
  const VisionCamera({
    required this.onCaptured,
    required this.onInitializationCompleted,
    required this.onDeviceOrientationChanged,
    required this.onPortraitCaptureAttempt,
    required this.showControls,
    required this.dependencies,
    super.key,
  });

  /// Recibe la foto y el cronómetro iniciado al accionar el disparador.
  final Future<void> Function(Uint8List, Stopwatch) onCaptured;

  /// Informa que la inicialización terminó, ya sea con vista previa o error.
  final VoidCallback onInitializationCompleted;

  /// Informa la orientación física sin permitir que rote toda la interfaz.
  final ValueChanged<VisionDeviceOrientation> onDeviceOrientationChanged;

  /// Solicita destacar la guía cuando se intenta capturar en vertical.
  final VoidCallback onPortraitCaptureAttempt;

  /// Muestra el disparador cuando finaliza la expansión circular del visor.
  final bool showControls;

  /// Casos de uso y constructor de vista previa inyectados por composición.
  final VisionCameraDependencies dependencies;

  @override
  State<VisionCamera> createState() => _VisionCameraState();
}

class _VisionCameraState extends State<VisionCamera> with WidgetsBindingObserver {
  VisionCameraInfo? _cameraInfo;
  String? _error;
  bool _capturing = false;
  int _generation = 0;
  VisionDeviceOrientation _captureButtonOrientation = VisionDeviceOrientation.portraitUp;
  VisionDeviceOrientation? _lastReportedOrientation;
  StreamSubscription<VisionDeviceOrientation>? _orientationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _orientationSubscription = widget.dependencies.watchOrientation().listen(
      _updateCaptureButtonOrientation,
      onError: _logOrientationError,
    );
    _scheduleCamera(active: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _orientationSubscription?.resume();
    } else {
      _orientationSubscription?.pause();
    }
    _scheduleCamera(active: state == AppLifecycleState.resumed);
  }

  void _updateCaptureButtonOrientation(VisionDeviceOrientation orientation) {
    if (!mounted) return;
    if (orientation != _captureButtonOrientation) {
      setState(() => _captureButtonOrientation = orientation);
    }
    if (_lastReportedOrientation != orientation) {
      _lastReportedOrientation = orientation;
      widget.onDeviceOrientationChanged(orientation);
    }
  }

  void _logOrientationError(Object error, StackTrace stackTrace) {
    developer.log(
      'No se pudo leer la orientación física del dispositivo',
      name: 'vision_weighing',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _scheduleCamera({required bool active}) {
    final generation = ++_generation;
    _cameraInfo = null;
    if (mounted) setState(() {});
    if (active) {
      unawaited(_openCamera(generation));
    } else {
      unawaited(widget.dependencies.dispose());
    }
  }

  Future<void> _openCamera(int generation) async {
    try {
      final info = await widget.dependencies.initialize();
      if (!mounted || generation != _generation) {
        await widget.dependencies.dispose();
        return;
      }
      setState(() {
        _cameraInfo = info;
        _error = null;
      });
      widget.onInitializationCompleted();
    } on Exception catch (error, stack) {
      developer.log('No se pudo inicializar cámara', name: 'vision_weighing', error: error, stackTrace: stack);
      if (mounted && generation == _generation) {
        setState(() => _error = VisionWeighingStrings.cameraError);
        widget.onInitializationCompleted();
      }
    }
  }

  Future<void> _capture() async {
    if (_cameraInfo == null || _capturing) return;
    // Se verifica el sensor antes de invocar al plugin: mantener el botón
    // activo permite explicar por qué la toma todavía no está habilitada.
    if (_captureButtonOrientation == VisionDeviceOrientation.portraitUp ||
        _captureButtonOrientation == VisionDeviceOrientation.portraitDown) {
      widget.onPortraitCaptureAttempt();
      return;
    }
    final generation = _generation;
    final captureTimer = Stopwatch()..start();
    setState(() => _capturing = true);
    try {
      final bytes = await widget.dependencies.capture();
      if (mounted && generation == _generation) await widget.onCaptured(bytes, captureTimer);
    } on Exception catch (error, stack) {
      developer.log('Falló la captura', name: 'vision_weighing', error: error, stackTrace: stack);
      if (mounted) setState(() => _error = VisionWeighingStrings.processingError);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    unawaited(_orientationSubscription?.cancel());
    unawaited(widget.dependencies.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraInfo = _cameraInfo;
    if (_error case final String error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTypography.formFieldValue.copyWith(color: AppColors.onPrimary),
            ),
            TextButton(
              onPressed: () {
                setState(() => _error = null);
                _scheduleCamera(active: true);
              },
              child: const Text(VisionWeighingStrings.retry),
            ),
          ],
        ),
      );
    }
    if (cameraInfo == null) return const Center(child: CircularProgressIndicator());
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final ratio = landscape ? cameraInfo.aspectRatio : 1 / cameraInfo.aspectRatio;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cubre el visor sin deformar la imagen; el excedente queda fuera de
        // pantalla. La fotografía conserva el encuadre completo del sensor.
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(width: ratio * 1000, height: 1000, child: widget.dependencies.previewBuilder(context)),
          ),
        ),
        const IgnorePointer(child: CustomPaint(painter: _CameraGridPainter())),
        if (widget.showControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                // Replica la posición de centerDocked: el centro del botón
                // coincide con el borde superior que tendría la navbar.
                padding: const EdgeInsets.only(
                  bottom: AppNavigationDimensions.bottomBarHeight - AppNavigationDimensions.centerButtonSize / 2,
                ),
                child: Center(
                  child: SizedBox.square(
                    dimension: AppNavigationDimensions.centerButtonSize,
                    child: FloatingActionButton(
                      heroTag: null,
                      tooltip: VisionWeighingStrings.capture,
                      onPressed: _capturing ? null : _capture,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledElevation: AppElevation.floatingButton,
                      elevation: AppElevation.floatingButton,
                      shape: const CircleBorder(),
                      child: AnimatedRotation(
                        turns: _iconTurns(_captureButtonOrientation),
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        child: SvgPicture.asset(
                          'assets/icons/camera.svg',
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(AppColors.onPrimary, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _iconTurns(VisionDeviceOrientation orientation) {
    // Se rota sólo el glifo dentro del botón. La vista, los controles y la
    // grilla permanecen quietos aunque cambie la orientación del sensor.
    return switch (orientation) {
      VisionDeviceOrientation.portraitUp => 0,
      VisionDeviceOrientation.landscapeRight => .25,
      VisionDeviceOrientation.portraitDown => .5,
      VisionDeviceOrientation.landscapeLeft => -.25,
    };
  }
}

/// Grilla de tercios discreta para orientar el encuadre sin dibujar al animal.
class _CameraGridPainter extends CustomPainter {
  const _CameraGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .2)
      ..strokeWidth = AppBorders.normal;
    for (var third = 1; third < 3; third++) {
      canvas
        ..drawLine(Offset(size.width * third / 3, 0), Offset(size.width * third / 3, size.height), paint)
        ..drawLine(Offset(0, size.height * third / 3), Offset(size.width, size.height * third / 3), paint);
    }
  }

  @override
  bool shouldRepaint(_CameraGridPainter oldDelegate) => false;
}
