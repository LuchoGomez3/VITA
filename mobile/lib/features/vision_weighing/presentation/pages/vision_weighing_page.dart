import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/navigation/camera_reveal_page.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_weighing_content.dart';
import 'package:image_picker/image_picker.dart';

/// Entrada independiente de la feature y dueña del ciclo de vida del Cubit.
class VisionWeighingPage extends StatelessWidget {
  /// Recibe la composición desde el router, sin importar la capa de datos.
  const VisionWeighingPage({required this.createCubit, super.key});

  /// Construye un coordinador exclusivo para esta sesión de captura.
  final VisionCaptureCubit Function() createCubit;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createCubit(),
    child: const _VisionWeighingView(),
  );
}

class _VisionWeighingView extends StatefulWidget {
  const _VisionWeighingView();

  @override
  State<_VisionWeighingView> createState() => _VisionWeighingViewState();
}

class _VisionWeighingViewState extends State<_VisionWeighingView> with TickerProviderStateMixin {
  bool _calibration = false;
  bool _selectingPhoto = false;
  bool _cameraInitializationCompleted = false;
  bool _cameraOpeningStarted = false;
  bool _cameraControlsVisible = false;
  bool _orientationWarningHighlighted = false;
  Timer? _orientationWarningTimer;
  DeviceOrientation _phoneOrientation = DeviceOrientation.portraitUp;
  bool _closing = false;
  bool _allowPop = false;
  double _cameraRevealInitialProgress = 0;
  DeviceOrientation _captureOrientation = DeviceOrientation.portraitUp;
  late final AnimationController _cameraLoadingController;
  late final AnimationController _cameraOpeningController;
  late final AnimationController _cameraClosingController;

  @override
  void initState() {
    super.initState();
    // La cámara conserva su composición vertical mientras el sensor continúa
    // informando cómo sostiene el operario el teléfono.
    unawaited(
      SystemChrome.setPreferredOrientations(
        const [DeviceOrientation.portraitUp],
      ),
    );
    _cameraLoadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _cameraOpeningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _cameraClosingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    unawaited(_cameraLoadingController.forward());
  }

  void _finishCameraInitialization() {
    _cameraInitializationCompleted = true;
    _startCameraRevealWhenReady();
  }

  void _updatePhoneOrientation(DeviceOrientation orientation) {
    if (_phoneOrientation == orientation) return;
    setState(() {
      _phoneOrientation = orientation;
      if (orientation == DeviceOrientation.landscapeLeft || orientation == DeviceOrientation.landscapeRight) {
        _orientationWarningTimer?.cancel();
        _orientationWarningHighlighted = false;
      }
    });
  }

  /// Destaca brevemente el aviso; cada toque reinicia el parpadeo y evita
  /// que un temporizador anterior apague la advertencia del último intento.
  void _flashOrientationWarning() {
    _orientationWarningTimer?.cancel();
    setState(() => _orientationWarningHighlighted = true);
    _orientationWarningTimer = Timer(const Duration(milliseconds: 600), () {
      setState(() => _orientationWarningHighlighted = false);
    });
  }

  Future<void> _processCapture(Uint8List bytes) {
    _captureOrientation = _phoneOrientation;
    return context.read<VisionCaptureCubit>().process(bytes);
  }

  /// Permite probar el flujo con una imagen de la galería. El análisis corrige
  /// su EXIF, por lo que no se aplica la rotación física de una toma en vivo.
  Future<void> _attachPhoto() async {
    if (_selectingPhoto) return;
    setState(() => _selectingPhoto = true);
    try {
      final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (!mounted || _closing) return;
      _captureOrientation = DeviceOrientation.portraitUp;
      await context.read<VisionCaptureCubit>().process(bytes);
    } on Exception catch (error, stack) {
      developer.log('No se pudo adjuntar la foto', name: 'vision_weighing', error: error, stackTrace: stack);
      if (mounted && !_closing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(VisionWeighingStrings.attachPhotoError)),
        );
      }
    } finally {
      if (mounted) setState(() => _selectingPhoto = false);
    }
  }

  void _startCameraRevealWhenReady() {
    if (_cameraInitializationCompleted && !_cameraOpeningStarted && !_closing) {
      _cameraLoadingController.stop();
      setState(() {
        _cameraRevealInitialProgress = _cameraLoadingController.value;
        _cameraOpeningStarted = true;
      });
      unawaited(_revealCamera());
    }
  }

  Future<void> _revealCamera() async {
    await _cameraOpeningController.forward();
    if (mounted) setState(() => _cameraControlsVisible = true);
  }

  Future<void> _closeCamera() async {
    if (_closing) return;
    setState(() => _closing = true);
    await _cameraClosingController.forward();
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _orientationWarningTimer?.cancel();
    // Una lista vacía devuelve el control de orientación al sistema operativo
    // para que el resto de la aplicación recupere su comportamiento previo.
    unawaited(SystemChrome.setPreferredOrientations(const []));
    _cameraLoadingController.dispose();
    _cameraOpeningController.dispose();
    _cameraClosingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _allowPop,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        unawaited(_closeCamera());
      }
    },
    child: BlocConsumer<VisionCaptureCubit, ResultState<VisionCapture>>(
      listener: _listenForCaptureError,
      builder: (context, state) => _buildAnimatedContent(
        VisionWeighingContent(
          state: state,
          calibration: _calibration,
          selectingPhoto: _selectingPhoto,
          onAttachPhoto: _attachPhoto,
          cameraControlsVisible: _cameraControlsVisible,
          phoneOrientation: _phoneOrientation,
          orientationWarningHighlighted: _orientationWarningHighlighted,
          onPortraitCaptureAttempt: _flashOrientationWarning,
          captureOrientation: _captureOrientation,
          onCaptured: _processCapture,
          onCameraInitializationCompleted: _finishCameraInitialization,
          onDeviceOrientationChanged: _updatePhoneOrientation,
          onCalibrationChanged: (value) {
            setState(() => _calibration = value);
          },
        ),
      ),
    ),
  );

  Future<void> _listenForCaptureError(
    BuildContext context,
    ResultState<VisionCapture> state,
  ) async {
    if (state case ResultError<VisionCapture>(:final error)) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text(VisionWeighingStrings.rejected),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(VisionWeighingStrings.retry),
            ),
          ],
        ),
      );
      if (context.mounted) context.read<VisionCaptureCubit>().retry();
    }
  }

  Widget _buildAnimatedContent(Widget content) {
    return IgnorePointer(
      ignoring: _closing,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_closing)
            AnimatedBuilder(
              animation: _cameraOpeningController,
              child: content,
              builder: (context, child) => CameraOpeningReveal(
                progress: _cameraOpeningController.value,
                initialProgress: _cameraRevealInitialProgress,
                visible: _cameraOpeningStarted,
                child: child!,
              ),
            ),
          if (!_closing && !_cameraOpeningStarted)
            AnimatedBuilder(
              animation: _cameraLoadingController,
              builder: (context, child) => CameraLoadingReveal(
                progress: _cameraLoadingController.value,
              ),
            ),
          AnimatedBuilder(
            animation: _cameraClosingController,
            builder: (context, child) {
              if (_cameraClosingController.isDismissed) {
                return const SizedBox.shrink();
              }
              // La ruta anterior queda visible fuera del círculo, que se
              // contrae hasta coincidir con el botón central de la navbar.
              return CameraRevealSurface(
                progress: 1 - _cameraClosingController.value,
              );
            },
          ),
          if (_closing || !_cameraControlsVisible) const CameraRevealButtonOverlay(),
        ],
      ),
    );
  }
}
