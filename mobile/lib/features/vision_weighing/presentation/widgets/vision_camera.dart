import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/app_navigation_dimensions.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Adaptador visual de cámara. Su estado local sólo posee recursos del plugin;
/// el análisis de la fotografía se delega al Cubit mediante [onCaptured].
class VisionCamera extends StatefulWidget {
  /// Crea una cámara sin audio y entrega los bytes de cada toma.
  const VisionCamera({
    required this.onCaptured,
    required this.onInitializationCompleted,
    required this.onDeviceOrientationChanged,
    required this.onPortraitCaptureAttempt,
    required this.showControls,
    super.key,
  });

  /// Recibe la foto original para el preprocesamiento local.
  final Future<void> Function(Uint8List) onCaptured;

  /// Informa que la inicialización terminó, ya sea con vista previa o error.
  final VoidCallback onInitializationCompleted;

  /// Informa la orientación física sin permitir que rote toda la interfaz.
  final ValueChanged<DeviceOrientation> onDeviceOrientationChanged;

  /// Solicita destacar la guía cuando se intenta capturar en vertical.
  final VoidCallback onPortraitCaptureAttempt;

  /// Muestra el disparador cuando finaliza la expansión circular del visor.
  final bool showControls;

  @override
  State<VisionCamera> createState() => _VisionCameraState();
}

class _VisionCameraState extends State<VisionCamera> with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  bool _capturing = false;
  int _generation = 0;
  DeviceOrientation _captureButtonOrientation = DeviceOrientation.portraitUp;
  DeviceOrientation? _lastReportedOrientation;
  StreamSubscription<AccelerometerEvent>? _orientationSubscription;
  // Serializa aperturas y cierres: el plugin no admite ambas operaciones a la vez.
  Future<void> _cameraOperation = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _orientationSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(_updateCaptureButtonOrientation, onError: _logOrientationError);
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

  void _updateCaptureButtonOrientation(AccelerometerEvent event) {
    final horizontalGravity = event.x.abs();
    final verticalGravity = event.y.abs();
    if (math.max(horizontalGravity, verticalGravity) < 4) return;

    final wasHorizontal = switch (_captureButtonOrientation) {
      DeviceOrientation.landscapeLeft || DeviceOrientation.landscapeRight => true,
      DeviceOrientation.portraitUp || DeviceOrientation.portraitDown => false,
    };
    // La histéresis evita que el indicador alterne repetidamente cuando el
    // teléfono queda cerca de los 45 grados durante el movimiento.
    final horizontal = wasHorizontal
        ? horizontalGravity > verticalGravity * .8
        : horizontalGravity > verticalGravity * 1.2;
    final orientation = horizontal
        ? event.x > 0
              ? DeviceOrientation.landscapeRight
              : DeviceOrientation.landscapeLeft
        : event.y > 0
        ? DeviceOrientation.portraitUp
        : DeviceOrientation.portraitDown;
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
    _cameraOperation = _cameraOperation.then((_) async {
      final previous = _controller;
      _controller = null;
      if (mounted) setState(() {});
      await previous?.dispose();
      if (!mounted || generation != _generation || !active) return;
      await _openCamera(generation);
    });
  }

  Future<void> _openCamera(int generation) async {
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (!mounted || generation != _generation) return;
      final rear = cameras.where((camera) => camera.lensDirection == CameraLensDirection.back).firstOrNull;
      if (rear == null) throw CameraException('NoRearCamera', 'Rear camera unavailable');
      controller = CameraController(rear, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _error = null;
      });
      widget.onInitializationCompleted();
    } on Exception catch (error, stack) {
      await controller?.dispose();
      developer.log('No se pudo inicializar cámara', name: 'vision_weighing', error: error, stackTrace: stack);
      if (mounted && generation == _generation) {
        setState(() => _error = VisionWeighingStrings.cameraError);
        widget.onInitializationCompleted();
      }
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) return;
    // Se verifica el sensor antes de invocar al plugin: mantener el botón
    // activo permite explicar por qué la toma todavía no está habilitada.
    if (_captureButtonOrientation == DeviceOrientation.portraitUp ||
        _captureButtonOrientation == DeviceOrientation.portraitDown) {
      widget.onPortraitCaptureAttempt();
      return;
    }
    final generation = _generation;
    setState(() => _capturing = true);
    try {
      final photo = await controller.takePicture();
      final bytes = await photo.readAsBytes();
      if (mounted && generation == _generation) await widget.onCaptured(bytes);
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
    unawaited(_cameraOperation.then((_) => _controller?.dispose()));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
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
    if (controller == null) return const Center(child: CircularProgressIndicator());
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final ratio = landscape ? controller.value.aspectRatio : 1 / controller.value.aspectRatio;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cubre el visor sin deformar la imagen; el excedente queda fuera de
        // pantalla. La fotografía conserva el encuadre completo del sensor.
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(width: ratio * 1000, height: 1000, child: CameraPreview(controller)),
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

  double _iconTurns(DeviceOrientation orientation) {
    // Se rota sólo el glifo dentro del botón. La vista, los controles y la
    // grilla permanecen quietos aunque cambie la orientación del sensor.
    return switch (orientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeRight => .25,
      DeviceOrientation.portraitDown => .5,
      DeviceOrientation.landscapeLeft => -.25,
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
