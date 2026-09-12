import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

// Acciones independientes: adjuntar una imagen no modifica la calibración.
enum _CameraSetting { calibration, attachPhoto }

/// Encabezado superpuesto con navegación, orientación y modo calibración.
class VisionCameraHeader extends StatelessWidget {
  /// Crea los controles superiores sin reducir el espacio del visor.
  const VisionCameraHeader({
    required this.orientation,
    required this.calibration,
    required this.busy,
    required this.onCalibrationChanged,
    required this.onAttachPhoto,
    this.orientationWarningHighlighted = false,
    super.key,
  });

  /// Orientación física informada por el acelerómetro.
  final DeviceOrientation orientation;

  /// Refuerza el aviso después de intentar una captura en vertical.
  final bool orientationWarningHighlighted;

  /// Indica si la captura solicitará el peso real de balanza.
  final bool calibration;

  /// Evita modificar el modo mientras se procesa una fotografía.
  final bool busy;

  /// Comunica los cambios del modo calibración a la página.
  final ValueChanged<bool> onCalibrationChanged;

  /// Solicita seleccionar una imagen local para probar la revisión.
  final VoidCallback onAttachPhoto;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.xs, AppSpacing.lg),
            child: Row(
              children: [
                const BackButton(color: Colors.white),
                Expanded(
                  child: _OrientationStatus(
                    orientation: orientation,
                    highlighted: orientationWarningHighlighted,
                  ),
                ),
                PopupMenuButton<_CameraSetting>(
                  enabled: !busy,
                  tooltip: VisionWeighingStrings.settings,
                  icon: Icon(
                    Icons.tune_rounded,
                    color: calibration ? Colors.lightGreenAccent : Colors.white,
                  ),
                  onSelected: (setting) {
                    switch (setting) {
                      case _CameraSetting.calibration:
                        onCalibrationChanged(!calibration);
                      case _CameraSetting.attachPhoto:
                        onAttachPhoto();
                    }
                  },
                  itemBuilder: (_) => [
                    CheckedPopupMenuItem(
                      value: _CameraSetting.calibration,
                      checked: calibration,
                      child: const Text(VisionWeighingStrings.calibration),
                    ),
                    const PopupMenuItem(
                      value: _CameraSetting.attachPhoto,
                      child: Row(
                        children: [
                          Icon(Icons.photo_library_outlined),
                          SizedBox(width: AppSpacing.xs),
                          Text(VisionWeighingStrings.attachPhoto),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrientationStatus extends StatelessWidget {
  const _OrientationStatus({required this.orientation, required this.highlighted});

  final DeviceOrientation orientation;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final horizontal = switch (orientation) {
      DeviceOrientation.landscapeLeft || DeviceOrientation.landscapeRight => true,
      DeviceOrientation.portraitUp || DeviceOrientation.portraitDown => false,
    };
    final emphasize = highlighted && !horizontal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          VisionWeighingStrings.offline,
          style: AppTypography.formFieldHelper.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AppSpacing.xxs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? AppSpacing.xxs : AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: horizontal ? AppColors.primary : (emphasize ? AppColors.error : Colors.black54),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: emphasize ? AppColors.onPrimary : Colors.transparent, width: AppBorders.bold),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _turnsFor(orientation),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  horizontal ? Icons.check_rounded : Icons.screen_rotation_rounded,
                  color: AppColors.onPrimary,
                  size: AppSpacing.lg,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: horizontal
                    ? const SizedBox.shrink()
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            VisionWeighingStrings.rotate,
                            style: (emphasize ? AppTypography.smallEmphasis : AppTypography.formFieldHelper).copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _turnsFor(DeviceOrientation orientation) {
    return switch (orientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeRight => .25,
      DeviceOrientation.portraitDown => .5,
      DeviceOrientation.landscapeLeft => -.25,
    };
  }
}
